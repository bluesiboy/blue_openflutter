import 'package:flutter/material.dart';
import '../services/dialog_service.dart';

class DialogUsageExample extends StatefulWidget {
  const DialogUsageExample({Key? key}) : super(key: key);

  @override
  State<DialogUsageExample> createState() => _DialogUsageExampleState();
}

class _DialogUsageExampleState extends State<DialogUsageExample> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _selectedOption = '选项1';
  final List<String> _options = ['选项1', '选项2', '选项3', '选项4'];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('弹框使用示例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '输入弹框',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showInputDialog(),
              child: const Text('显示输入弹框'),
            ),
            const SizedBox(height: 16),
            const Text(
              '选择弹框',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showSelectionDialog(),
              child: const Text('显示选择弹框'),
            ),
            const SizedBox(height: 16),
            const Text(
              '通用Widget弹框',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showCustomDialog(),
              child: const Text('显示自定义弹框'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showComplexWidgetDialog(),
              child: const Text('显示复杂Widget弹框'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showNoTitleDialog(),
              child: const Text('显示无标题弹框'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showSimpleDialog(),
              child: const Text('显示简单弹框'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showFullScreenDialog(),
              child: const Text('显示全屏弹框'),
            ),
            const SizedBox(height: 16),
            const Text(
              '头像选择弹框',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showAvatarDialog(),
              child: const Text('显示头像选择弹框'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示输入弹框示例
  Future<void> _showInputDialog() async {
    _nameController.clear();
    final result = await DialogService.showGlassInputDialog(
      context: context,
      title: '输入姓名',
      controller: _nameController,
      hintText: '请输入您的姓名',
      maxLines: 1,
      maxLength: 20,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _nameController.text),
          child: const Text('确定'),
        ),
      ],
    );

    if (result != null && result is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('您输入的姓名是: $result')),
      );
    }
  }

  /// 显示选择弹框示例
  Future<void> _showSelectionDialog() async {
    await DialogService.showGlassSelectionDialog(
      context: context,
      title: '选择选项',
      children: _options
          .map((option) => ListTile(
                title: Text(option),
                trailing: _selectedOption == option ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() {
                    _selectedOption = option;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('您选择了: $option')),
                  );
                },
              ))
          .toList(),
    );
  }

  /// 显示自定义弹框示例
  Future<void> _showCustomDialog() async {
    _bioController.clear();
    final result = await DialogService.showGlassDialog(
      context: context,
      title: '自定义内容弹框',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('这是一个自定义内容的弹框示例'),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(
              hintText: '请输入备注信息',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _bioController.text),
          child: const Text('提交'),
        ),
      ],
    );

    if (result != null && result is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('您输入的备注是: $result')),
      );
    }
  }

  /// 显示复杂Widget弹框示例
  Future<void> _showComplexWidgetDialog() async {
    await DialogService.showGlassDialog(
      context: context,
      title: '复杂Widget弹框',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图片
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.image,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // 文本内容
          const Text(
            '这是一个包含多种Widget的复杂弹框示例',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '您可以在这里放置任何Flutter Widget，包括图片、按钮、表单、列表等。',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 按钮组
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('点击了按钮1')),
                    );
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('喜欢'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('点击了按钮2')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('分享'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 进度条
          const LinearProgressIndicator(value: 0.7),
          const SizedBox(height: 8),
          const Text('加载进度: 70%', style: TextStyle(fontSize: 12)),
        ],
      ),
      height: 400,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  /// 显示无标题弹框示例
  Future<void> _showNoTitleDialog() async {
    await DialogService.showGlassDialog(
      context: context,
      title: null, // 不显示标题
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            '操作成功！',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '您的操作已经成功完成',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
  }

  /// 显示全屏弹框示例
  Future<void> _showFullScreenDialog() async {
    await DialogService.showFullScreenGlassDialog(
      context: context,
      title: '全屏弹框',
      content: Column(
        children: [
          // 模拟列表内容
          ...List.generate(
              20,
              (index) => ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text('列表项 ${index + 1}'),
                    subtitle: Text('这是第 ${index + 1} 个列表项的详细描述'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('点击了列表项 ${index + 1}')),
                      );
                    },
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
  }

  /// 显示简单弹框示例
  Future<void> _showSimpleDialog() async {
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
  }

  /// 显示头像选择弹框示例
  Future<void> _showAvatarDialog() async {
    // 模拟头像文件列表
    final avatarFiles = [
      'assets/avatar/avatar1.jpg',
      'assets/avatar/avatar2.jpg',
      'assets/avatar/avatar3.jpg',
      'assets/avatar/avatar4.jpg',
    ];

    final selectedAvatar = await DialogService.showAvatarSelectionDialog(
      context: context,
      avatarFiles: avatarFiles,
      selectedAvatar: null,
    );

    if (selectedAvatar != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('您选择的头像: $selectedAvatar')),
      );
    }
  }
}
