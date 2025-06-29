# DialogService 全局弹框服务

`DialogService` 是一个全局的玻璃态弹框服务，提供了多种类型的弹框接口，可以在应用的任何页面中调用。

## 功能特性

- 🎨 统一的玻璃态设计风格
- 🌙 自动适配深色/浅色主题
- 📱 响应式设计，适配不同屏幕尺寸
- 🔧 高度可定制化
- 🚀 简单易用的API

## 弹框类型

### 1. 输入弹框 (showGlassInputDialog)

用于文本输入的场景，如编辑昵称、个性签名等。

```dart
final result = await DialogService.showGlassInputDialog(
  context: context,
  title: '编辑昵称',
  controller: textController,
  hintText: '请输入昵称',
  maxLines: 1,
  maxLength: 16,
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('取消'),
    ),
    TextButton(
      onPressed: () => Navigator.pop(context, true),
      child: const Text('确定'),
    ),
  ],
);
```

**参数说明：**
- `context`: BuildContext
- `title`: 弹框标题
- `controller`: 文本控制器
- `hintText`: 输入框提示文本
- `maxLines`: 最大行数（默认1）
- `maxLength`: 最大字符数（默认50）
- `validator`: 验证函数（可选）
- `actions`: 自定义操作按钮（可选）

### 2. 选择弹框 (showGlassSelectionDialog)

用于选项选择的场景，如选择性别、城市等。

```dart
await DialogService.showGlassSelectionDialog(
  context: context,
  title: '选择性别',
  children: [
    ListTile(
      title: const Text('男'),
      trailing: _selectedGender == '男' 
          ? const Icon(Icons.check, color: Colors.blue) 
          : null,
      onTap: () {
        setState(() => _selectedGender = '男');
        Navigator.pop(context);
      },
    ),
    ListTile(
      title: const Text('女'),
      trailing: _selectedGender == '女' 
          ? const Icon(Icons.check, color: Colors.blue) 
          : null,
      onTap: () {
        setState(() => _selectedGender = '女');
        Navigator.pop(context);
      },
    ),
  ],
);
```

**参数说明：**
- `context`: BuildContext
- `title`: 弹框标题
- `children`: 选项列表
- `height`: 弹框高度（可选）

### 3. 头像选择弹框 (showAvatarSelectionDialog)

专门用于头像选择的网格布局弹框。

```dart
final selectedAvatar = await DialogService.showAvatarSelectionDialog(
  context: context,
  avatarFiles: avatarFiles,
  selectedAvatar: currentAvatar,
);
```

**参数说明：**
- `context`: BuildContext
- `avatarFiles`: 头像文件路径列表
- `selectedAvatar`: 当前选中的头像

### 4. 通用弹框 (showGlassDialog)

用于显示任意Widget内容的弹框，这是最灵活的弹框类型。

```dart
final result = await DialogService.showGlassDialog(
  context: context,
  title: '自定义弹框',
  content: Column(
    children: [
      const Text('这是自定义内容'),
      const SizedBox(height: 16),
      TextField(
        decoration: const InputDecoration(
          hintText: '请输入内容',
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('按钮1'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {},
            child: const Text('按钮2'),
          ),
        ],
      ),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('取消'),
    ),
    TextButton(
      onPressed: () => Navigator.pop(context, '提交'),
      child: const Text('提交'),
    ),
  ],
);
```

**参数说明：**
- `context`: BuildContext
- `title`: 弹框标题（可选，传null则不显示标题）
- `content`: 自定义Widget内容
- `actions`: 操作按钮（可选）
- `width`: 弹框宽度（可选，默认320）
- `height`: 弹框高度（可选，默认280）
- `padding`: 内边距（可选，默认20）
- `showTitle`: 是否显示标题（默认true）
- `scrollable`: 内容是否可滚动（默认true）
- `barrierDismissible`: 点击背景是否关闭（默认true）
- `barrierColor`: 背景遮罩颜色（可选）
- `barrierLabel`: 无障碍标签（可选）
- `useSafeArea`: 是否使用安全区域（默认true）
- `useRootNavigator`: 是否使用根导航器（默认true）
- `routeSettings`: 路由设置（可选）

### 5. 简单弹框 (showSimpleGlassDialog)

无标题的简化版弹框，只包含内容。

```dart
await DialogService.showSimpleGlassDialog(
  context: context,
  content: const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('加载中...'),
      ],
    ),
  ),
);
```

### 6. 全屏弹框 (showFullScreenGlassDialog)

占据大部分屏幕空间的弹框，适合显示大量内容。

```dart
await DialogService.showFullScreenGlassDialog(
  context: context,
  title: '全屏弹框',
  content: Column(
    children: [
      // 大量内容...
      ...List.generate(20, (index) => ListTile(
        title: Text('列表项 ${index + 1}'),
        subtitle: Text('详细描述 ${index + 1}'),
      )),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('关闭'),
    ),
  ],
);
```

## 高级用法

### showGlassDialog 的实际应用场景

`showGlassDialog` 是最灵活的弹框方法，可以包含任何Flutter Widget。以下是一些实际应用场景：

#### 1. 表单弹框

```dart
Future<void> _showFormDialog() async {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  
  final result = await DialogService.showGlassDialog(
    context: context,
    title: '用户信息',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '姓名',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: '邮箱',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, {
          'name': nameController.text,
          'email': emailController.text,
        }),
        child: const Text('提交'),
      ),
    ],
  );
}
```

#### 2. 图片预览弹框

```dart
Future<void> _showImagePreviewDialog() async {
  await DialogService.showGlassDialog(
    context: context,
    title: '图片预览',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage('https://example.com/image.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '这是一张美丽的图片',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    ),
    height: 350,
  );
}
```

#### 3. 设置弹框

```dart
Future<void> _showSettingsDialog() async {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  
  await DialogService.showGlassDialog(
    context: context,
    title: '应用设置',
    content: StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('推送通知'),
            subtitle: const Text('接收应用推送通知'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),
          SwitchListTile(
            title: const Text('深色模式'),
            subtitle: const Text('启用深色主题'),
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() => darkModeEnabled = value);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于应用'),
            subtitle: const Text('版本 1.0.0'),
            onTap: () {
              // 处理点击事件
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      ElevatedButton(
        onPressed: () {
          // 保存设置
          Navigator.pop(context);
        },
        child: const Text('保存'),
      ),
    ],
  );
}
```

#### 4. 加载状态弹框

```dart
Future<void> _showLoadingDialog() async {
  await DialogService.showSimpleGlassDialog(
    context: context,
    content: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('正在处理...'),
        SizedBox(height: 8),
        Text(
          '请稍候，我们正在为您处理请求',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    barrierDismissible: false, // 防止用户点击背景关闭
  );
}
```

#### 5. 确认操作弹框

```dart
Future<bool> _showConfirmDialog() async {
  final result = await DialogService.showGlassDialog<bool>(
    context: context,
    title: '确认删除',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.warning,
          size: 60,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        const Text(
          '您确定要删除这个项目吗？',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          '此操作无法撤销',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('取消'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('删除'),
      ),
    ],
  );
  
  return result ?? false;
}
```

### 自定义样式和动画

您还可以通过传递自定义的 `barrierColor`、`transitionDuration` 等参数来自定义弹框的外观和行为：

```dart
await DialogService.showGlassDialog(
  context: context,
  title: '自定义样式',
  content: const Text('这是一个自定义样式的弹框'),
  barrierColor: Colors.black.withOpacity(0.8),
  width: 400,
  height: 300,
  padding: const EdgeInsets.all(24),
);
```

## 使用示例

### 在页面中导入

```dart
import '../services/dialog_service.dart';
```

### 完整使用示例

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showInputDialog() async {
    _controller.clear();
    final result = await DialogService.showGlassInputDialog(
      context: context,
      title: '输入信息',
      controller: _controller,
      hintText: '请输入内容',
      maxLines: 3,
      maxLength: 100,
    );
    
    if (result == true) {
      // 用户点击了确定按钮
      print('输入的内容: ${_controller.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('示例页面')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showInputDialog,
          child: const Text('显示弹框'),
        ),
      ),
    );
  }
}
```

## 注意事项

1. **控制器管理**: 使用输入弹框时，请确保正确管理 `TextEditingController` 的生命周期
2. **返回值处理**: 弹框方法返回 `Future<T?>`，需要正确处理返回值
3. **主题适配**: 弹框会自动适配当前主题，无需手动设置颜色
4. **内存管理**: 在页面销毁时记得释放控制器资源

## 扩展功能

如果需要添加新的弹框类型，可以在 `DialogService` 类中添加新的静态方法。建议遵循现有的设计模式和命名规范。 