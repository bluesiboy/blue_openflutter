import 'package:blue_openflutter/pages/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/chat_item.dart';
import '../models/message_model.dart';

class ChatListLayout {
  // ===================== 常规模式参数 =====================
  /// 聊天项高度（常规模式）
  static const double itemHeight = 68;

  /// 头像尺寸（常规模式）
  static const double avatarSize = 48;

  /// 头像炫光尺寸（常规模式）
  static const double avatarGlow = 50;

  /// 聊天项上下内边距（常规模式）
  static const double paddingV = 6;

  /// 聊天项左右内边距（常规模式）
  static const double paddingH = 8;

  /// 名字字体大小（常规模式）
  static const double nameFont = 15;

  /// 消息字体大小（常规模式）
  static const double msgFont = 13;

  /// 时间字体大小（常规模式）
  static const double timeFont = 11;

  // ===================== 列表整体外边距 =====================
  /// 列表左侧外边距
  static const double listPaddingLeft = 12;

  /// 列表右侧外边距
  static const double listPaddingRight = 12;

  /// 列表顶部外边距
  static const double listPaddingTop = 8;

  /// 列表底部外边距
  static const double listPaddingBottom = 8;

  // ===================== 卡片样式参数 =====================
  /// 聊天卡片圆角
  static const double cardRadius = 18;

  /// 聊天卡片毛玻璃模糊度
  static const double cardBlur = 18;

  /// 聊天卡片边框宽度
  static const double cardBorder = 1.0;
}

// ===================== 工具方法 =====================
/// 格式化时间为12小时制+AM/PM
String formatTime12Hour(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
  return "$hour:$minute $ampm";
}

// ===================== 聊天内容构建 =====================
Widget buildChatContentWithUnreadAnim(
  ChatItem chat,
  bool isDark,
  double avatarSize,
  double avatarGlow,
  double paddingH,
  double nameFont,
  double msgFont,
  double timeFont,
) {
  final isDraft = chat.isDraft;
  return Padding(
    padding: EdgeInsets.only(right: paddingH),
    child: Row(
      children: [
        Padding(
          padding: EdgeInsets.all(paddingH),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarGlow,
                height: avatarGlow,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.blueGrey.withOpacity(0.28) : Colors.blueAccent.withOpacity(0.18),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              ClipOval(
                child: Image.asset(
                  chat.avatar,
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stack) => Container(
                    width: avatarSize,
                    height: avatarSize,
                    color: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.white54, size: avatarSize * 0.6),
                  ),
                ),
              ),
              if (chat.isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: avatarSize * 0.28,
                    height: avatarSize * 0.28,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              if (chat.isGroup)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.groups, size: avatarSize * 0.38, color: Colors.white),
                  ),
                ),
              if (chat.isPinned)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Icon(Icons.push_pin, size: avatarSize * 0.38, color: Colors.orangeAccent.withOpacity(0.85)),
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: nameFont,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chat.isMuted)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(Icons.volume_off, size: 16, color: Colors.blueGrey.withOpacity(0.7)),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      chat.time,
                      style: TextStyle(
                        fontSize: timeFont,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isDraft)
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text('[草稿]',
                          style: TextStyle(color: Colors.red, fontSize: msgFont, fontWeight: FontWeight.bold)),
                    ),
                  if (chat.lastMessage.type == 'image')
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(Icons.image, size: msgFont + 4, color: Colors.blueAccent),
                    ),
                  if (chat.lastMessage.type == 'voice')
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(Icons.keyboard_voice, size: msgFont + 4, color: Colors.green),
                    ),
                  if (chat.lastMessage.type == 'file')
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(Icons.insert_drive_file, size: msgFont + 4, color: Colors.orange),
                    ),
                  if (chat.lastMessage.type == 'emoji')
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Text('😄', style: TextStyle(fontSize: msgFont + 4)),
                    ),
                  Expanded(
                    child: Text(
                      chat.lastMessage.content,
                      style: TextStyle(
                        fontSize: msgFont,
                        color: isDraft ? Colors.red : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: isDraft ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: (chat.unread > 0)
                        ? Container(
                            key: ValueKey(chat.unread),
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${chat.unread}',
                              style: TextStyle(color: Colors.white, fontSize: msgFont - 1, fontWeight: FontWeight.bold),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ===================== 聊天项组件 =====================
/// 聊天列表单项组件，支持滑动操作、点击进入详情、高亮动画等
class ChatListItem extends StatefulWidget {
  final ChatItem chat;
  final int index;
  final bool highlight;
  final Function() onHighlightEnd;
  final double itemHeight;
  final double avatarSize;
  final double avatarGlow;
  final double paddingV;
  final double paddingH;
  final double nameFont;
  final double msgFont;
  final double timeFont;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleMute;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.index,
    required this.highlight,
    required this.onHighlightEnd,
    required this.itemHeight,
    required this.avatarSize,
    required this.avatarGlow,
    required this.paddingV,
    required this.paddingH,
    required this.nameFont,
    required this.msgFont,
    required this.timeFont,
    required this.isDark,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleMute,
  });

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _handleHighlightChange();
  }

  @override
  void didUpdateWidget(covariant ChatListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight != oldWidget.highlight) {
      _handleHighlightChange();
    }
  }

  /// 处理高亮动画的触发与结束
  void _handleHighlightChange() {
    if (widget.highlight && !_controller.isAnimating) {
      _controller.forward(from: 0);
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onHighlightEnd();
        }
      });
    } else if (!widget.highlight && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final highlight = widget.highlight;
    final isDark = widget.isDark;
    final itemHeight = widget.itemHeight;
    final avatarSize = widget.avatarSize;
    final avatarGlow = widget.avatarGlow;
    final paddingH = widget.paddingH;
    final nameFont = widget.nameFont;
    final msgFont = widget.msgFont;
    final timeFont = widget.timeFont;

    return Slidable(
      key: ValueKey(chat.avatar + chat.name),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.42,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onTogglePin(),
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            icon: Icons.push_pin,
            label: chat.isPinned ? '取消置顶' : '置顶',
          ),
          SlidableAction(
            onPressed: (_) => widget.onToggleMute(),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            icon: Icons.volume_off,
            label: chat.isMuted ? '取消免打扰' : '免打扰',
          ),
          SlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.paddingV),
        child: InkWell(
          borderRadius: BorderRadius.circular(ChatListLayout.cardRadius),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ChatDetailPage(
                  userName: chat.name,
                  avatar: chat.avatar,
                  isGroup: chat.isGroup,
                  isOnline: chat.isOnline,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (highlight)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (ctx, child) {
                    return CustomPaint(
                      size: Size(double.infinity, itemHeight),
                      painter: FlowingBorderPainter(
                        progress: Curves.linear.transform(_controller.value),
                        borderRadius: ChatListLayout.cardRadius,
                        borderWidth: 2.2,
                        isDark: isDark,
                      ),
                    );
                  },
                )
              else
                CustomPaint(
                  size: Size(double.infinity, itemHeight),
                  painter: StaticBorderPainter(
                    borderRadius: ChatListLayout.cardRadius,
                    borderWidth: 2.2,
                    isDark: isDark,
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: itemHeight,
                  borderRadius: ChatListLayout.cardRadius,
                  blur: ChatListLayout.cardBlur,
                  border: ChatListLayout.cardBorder,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(isDark ? 0.13 : 0.18),
                      Colors.white.withOpacity(isDark ? 0.05 : 0.09),
                    ],
                    stops: const [0.1, 1],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(isDark ? 0.16 : 0.25),
                      Colors.white.withOpacity(isDark ? 0.12 : 0.18),
                    ],
                  ),
                  child: buildChatContentWithUnreadAnim(
                    chat,
                    isDark,
                    avatarSize,
                    avatarGlow,
                    paddingH,
                    nameFont,
                    msgFont,
                    timeFont,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== 主页面 =====================
/// 聊天列表主题页面，包含分组、滚动、动画、拖拽排序等功能
class ChatListThemePage extends StatefulWidget {
  const ChatListThemePage({Key? key}) : super(key: key);

  @override
  State<ChatListThemePage> createState() => _ChatListThemePageState();
}

class _ChatListThemePageState extends State<ChatListThemePage> with SingleTickerProviderStateMixin {
  List<String> _avatarFiles = [];
  List<ChatItem> _chatList = [];
  bool _didAnimate = false;

  // 缓存分组结果，避免重复计算
  List<ChatItem>? _cachedPinnedChats;
  List<ChatItem>? _cachedNormalChats;

  // 滚动控制器
  late ScrollController _scrollController;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadAvatars();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听器，控制"回到顶部"按钮显示
  void _onScroll() {
    final showButton = _scrollController.offset > 200;
    if (showButton != _showScrollToTop) {
      setState(() {
        _showScrollToTop = showButton;
      });
    }
  }

  /// 平滑滚动到顶部
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  /// 平滑滚动到底部
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  /// 平滑滚动到指定聊天项
  void _scrollToChat(int chatIndex) {
    if (chatIndex < 0 || chatIndex >= _chatList.length) return;

    final chat = _chatList[chatIndex];
    final isPinned = chat.isPinned;

    // 计算目标位置
    double targetOffset = 0;

    if (isPinned) {
      // 如果是置顶项，计算在置顶组中的位置
      final pinnedIndex = _pinnedChats.indexOf(chat);
      if (pinnedIndex >= 0) {
        targetOffset = _calculatePinnedChatOffset(pinnedIndex);
      }
    } else {
      // 如果是普通项，计算在普通组中的位置
      final normalIndex = _normalChats.indexOf(chat);
      if (normalIndex >= 0) {
        targetOffset = _calculateNormalChatOffset(normalIndex);
      }
    }

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  /// 计算置顶聊天项的位置
  double _calculatePinnedChatOffset(int pinnedIndex) {
    double offset = 0;

    // 添加置顶标题的高度
    offset += 40; // 标题高度 + padding

    // 添加之前置顶项的高度
    offset += pinnedIndex * (ChatListLayout.itemHeight + ChatListLayout.paddingV * 2);

    return offset;
  }

  /// 计算普通聊天项的位置
  double _calculateNormalChatOffset(int normalIndex) {
    double offset = 0;

    // 添加置顶组的高度
    if (_pinnedChats.isNotEmpty) {
      offset += 40; // 置顶标题高度
      offset += _pinnedChats.length * (ChatListLayout.itemHeight + ChatListLayout.paddingV * 2);
    }

    // 添加聊天标题的高度
    offset += 40; // 聊天标题高度

    // 添加之前普通项的高度
    offset += normalIndex * (ChatListLayout.itemHeight + ChatListLayout.paddingV * 2);

    return offset;
  }

  /// 加载头像资源并生成聊天数据
  Future<void> _loadAvatars() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final avatarFiles = manifestMap.keys
        .where((String key) => key.startsWith('assets/avatar/') && (key.endsWith('.jpg') || key.endsWith('.png')))
        .toList();
    setState(() {
      _avatarFiles = avatarFiles;
      _chatList = [
        ...List.generate(_avatarFiles.length, (i) => generateMsg(i)),
        ...List.generate(_avatarFiles.length, (i) => generateMsg(i)),
      ];
      _clearCache();
    });
  }

  /// 生成模拟聊天数据
  ChatItem generateMsg(int i) {
    return ChatItem(
      avatar: _avatarFiles[i],
      name: '用户${i + 1}',
      lastMessage: Message(
        type: i % 5 == 0 ? 'image' : (i % 5 == 1 ? 'voice' : (i % 5 == 2 ? 'file' : (i % 5 == 3 ? 'emoji' : 'text'))),
        content: i % 5 == 0
            ? '[图片] 生活照.jpg'
            : i % 5 == 1
                ? '[语音] 00:12'
                : i % 5 == 2
                    ? '[文件] 文档.pdf'
                    : i % 5 == 3
                        ? '[表情] 😄'
                        : (i % 4 == 0 ? '[草稿] 这是未发送的消息' : '这是一条很酷炫的消息内容，编号${i + 1}。'),
        time: '${10 + i}:0${i % 6} AM',
      ),
      time: '${10 + i}:0${i % 6} AM',
      unread: i % 3 == 0 ? (i % 5 + 1) : 0,
      isPinned: i % 5 == 0,
      isMuted: i % 4 == 0,
      isGroup: i % 6 == 0,
      isDraft: i % 4 == 0,
      isOnline: i % 2 == 0,
    );
  }

  /// 清除分组缓存，强制重新计算
  void _clearCache() {
    _cachedPinnedChats = null;
    _cachedNormalChats = null;
  }

  /// 获取置顶聊天分组
  List<ChatItem> get _pinnedChats {
    _cachedPinnedChats ??= _chatList.where((c) => c.isPinned).toList();
    return _cachedPinnedChats!;
  }

  /// 获取普通聊天分组
  List<ChatItem> get _normalChats {
    _cachedNormalChats ??= _chatList.where((c) => !c.isPinned).toList();
    return _cachedNormalChats!;
  }

  /// 拖拽排序，仅支持普通分组
  void _onReorderNormal(int oldIndex, int newIndex) {
    setState(() {
      final normalIndexes = _chatList.asMap().entries.where((e) => !e.value.isPinned).map((e) => e.key).toList();
      if (normalIndexes.isEmpty) return;
      final from = normalIndexes[oldIndex];
      final to = newIndex >= normalIndexes.length
          ? _chatList.length
          : normalIndexes[newIndex > oldIndex ? newIndex - 1 : newIndex];
      final item = _chatList.removeAt(from);
      _chatList.insert(to, item);
      _clearCache();
    });
  }

  /// 平滑滚动到指定聊天项并高亮
  void _scrollToChatAndHighlight(int chatIndex) {
    if (chatIndex < 0 || chatIndex >= _chatList.length) return;

    // 先滚动到指定位置
    _scrollToChat(chatIndex);

    // 延迟一下再高亮，确保滚动完成
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        triggerNewMessageAnim(chatIndex, increaseUnread: false);
      }
    });
  }

  /// 自定义动画滚动效果（波浪式弹性滚动）
  void _scrollWithCustomAnimation() {
    if (_chatList.isEmpty) return;

    // 创建一个波浪式的滚动动画
    final random = Random();
    final targetIndex = random.nextInt(_chatList.length);
    final targetOffset = _calculateChatOffset(targetIndex);

    // 使用弹性曲线创建有趣的滚动效果
    _scrollController
        .animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
    )
        .then((_) {
      // 滚动完成后高亮显示
      if (mounted) {
        triggerNewMessageAnim(targetIndex, increaseUnread: false);
      }
    });
  }

  /// 计算任意聊天项的位置
  double _calculateChatOffset(int chatIndex) {
    if (chatIndex < 0 || chatIndex >= _chatList.length) return 0;

    final chat = _chatList[chatIndex];
    final isPinned = chat.isPinned;

    if (isPinned) {
      final pinnedIndex = _pinnedChats.indexOf(chat);
      if (pinnedIndex >= 0) {
        return _calculatePinnedChatOffset(pinnedIndex);
      }
    } else {
      final normalIndex = _normalChats.indexOf(chat);
      if (normalIndex >= 0) {
        return _calculateNormalChatOffset(normalIndex);
      }
    }

    return 0;
  }

  /// 触发指定聊天项的新消息动画（高亮流光），可选是否未读+1
  void triggerNewMessageAnim(int chatIndex, {bool increaseUnread = true}) {
    setState(() {
      if (chatIndex >= 0 && chatIndex < _chatList.length) {
        if (increaseUnread) {
          _chatList[chatIndex].unread++;
        }
        _chatList[chatIndex].highlight = true;

        // 更新时间（12小时制+AM/PM）
        final now = DateTime.now();
        final timeStr = formatTime12Hour(now);
        _chatList[chatIndex].time = timeStr;
        _chatList[chatIndex].lastMessage.time = timeStr;

        // 无论分组，直接插入到列表最前面
        final chat = _chatList.removeAt(chatIndex);
        _chatList.insert(0, chat);
        _clearCache();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('聊天列表', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active),
                tooltip: '模拟新消息',
                onPressed: () {
                  // 随机将一个普通聊天项的unread+1，并高亮提醒
                  if (_normalChats.isNotEmpty) {
                    final idx = _chatList.indexOf(_normalChats[Random().nextInt(_normalChats.length)]);
                    if (idx >= 0) {
                      triggerNewMessageAnim(idx, increaseUnread: true);
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: '滚动到顶部',
                onPressed: _scrollToTop,
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: '滚动到底部',
                onPressed: _scrollToBottom,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: '更多操作',
                onSelected: (value) {
                  switch (value) {
                    case 'scroll_to_first':
                      if (_chatList.isNotEmpty) {
                        _scrollToChat(0);
                      }
                      break;
                    case 'scroll_to_last':
                      if (_chatList.isNotEmpty) {
                        _scrollToChat(_chatList.length - 1);
                      }
                      break;
                    case 'scroll_to_pinned':
                      if (_pinnedChats.isNotEmpty) {
                        final firstPinnedIndex = _chatList.indexOf(_pinnedChats.first);
                        _scrollToChat(firstPinnedIndex);
                      }
                      break;
                    case 'scroll_to_normal':
                      if (_normalChats.isNotEmpty) {
                        final firstNormalIndex = _chatList.indexOf(_normalChats.first);
                        _scrollToChat(firstNormalIndex);
                      }
                      break;
                    case 'highlight_random':
                      if (_chatList.isNotEmpty) {
                        final randomIndex = Random().nextInt(_chatList.length);
                        _scrollToChatAndHighlight(randomIndex);
                      }
                      break;
                    case 'scroll_with_animation':
                      _scrollWithCustomAnimation();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'scroll_to_first',
                    child: Row(
                      children: [
                        Icon(Icons.first_page),
                        SizedBox(width: 8),
                        Text('滚动到第一个'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'scroll_to_last',
                    child: Row(
                      children: [
                        Icon(Icons.last_page),
                        SizedBox(width: 8),
                        Text('滚动到最后一个'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'scroll_to_pinned',
                    child: Row(
                      children: [
                        Icon(Icons.push_pin),
                        SizedBox(width: 8),
                        Text('滚动到置顶'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'scroll_to_normal',
                    child: Row(
                      children: [
                        Icon(Icons.chat),
                        SizedBox(width: 8),
                        Text('滚动到聊天'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'highlight_random',
                    child: Row(
                      children: [
                        Icon(Icons.flash_on),
                        SizedBox(width: 8),
                        Text('随机高亮'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'scroll_with_animation',
                    child: Row(
                      children: [
                        Icon(Icons.animation),
                        SizedBox(width: 8),
                        Text('动画滚动'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SlidableAutoCloseBehavior(
            child: SafeArea(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  left: ChatListLayout.listPaddingLeft,
                  right: ChatListLayout.listPaddingRight,
                  top: ChatListLayout.listPaddingTop,
                  bottom: ChatListLayout.listPaddingBottom,
                ),
                children: [
                  if (_pinnedChats.isNotEmpty) ...[
                    _buildGroupTitle('置顶'),
                    ..._buildChatItemsWithAnimation(_pinnedChats, 0),
                  ],
                  _buildGroupTitle('聊天'),
                  SizedBox(
                    height: _normalChats.length * (ChatListLayout.itemHeight + ChatListLayout.paddingV * 2) + 8,
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _normalChats.length,
                      onReorder: _onReorderNormal,
                      itemBuilder: (ctx, i) {
                        final c = _normalChats[i];
                        final order = i + _pinnedChats.length;
                        final key = ValueKey("${c.avatar}${c.name}_$i");

                        if (!_didAnimate) {
                          Future.microtask(() => _didAnimate = true);
                          return KeyedSubtree(
                            key: key,
                            child: _buildChatItem(c, _chatList.indexOf(c), animationOrder: order)
                                .animate(delay: Duration(milliseconds: 40 * order))
                                .fadeIn(duration: 400.ms),
                          );
                        } else {
                          return KeyedSubtree(
                            key: key,
                            child: _buildChatItem(c, _chatList.indexOf(c), animationOrder: order),
                          );
                        }
                      },
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 44,
                          child: child,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 滚动到顶部浮动按钮
          if (_showScrollToTop)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blueAccent.withOpacity(0.9),
                foregroundColor: Colors.white,
                onPressed: _scrollToTop,
                child: const Icon(Icons.keyboard_arrow_up),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 300.ms),
            ),
        ],
      ),
    );
  }

  /// 构建分组下的聊天项（带动画）
  List<Widget> _buildChatItemsWithAnimation(List<ChatItem> chats, int startOrder) {
    return chats
        .asMap()
        .entries
        .map((e) => _buildChatItem(e.value, _chatList.indexOf(e.value), animationOrder: e.key + startOrder)
            .animate(delay: Duration(milliseconds: 40 * (e.key + startOrder)))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms))
        .toList();
  }

  /// 构建页面背景渐变
  Widget _buildBackground() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? const [
                  Color(0xFF232526),
                  Color(0xFF414345),
                  Color(0xFF0f2027),
                  Color(0xFF2c5364),
                ]
              : const [
                  Color(0xFFe0eafc),
                  Color(0xFFcfdef3),
                  Color(0xFFa1c4fd),
                  Color(0xFFc2e9fb),
                  Color(0xFFfbc2eb),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  /// 构建单个聊天项
  Widget _buildChatItem(ChatItem chat, int index, {int? animationOrder}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChatListItem(
      chat: chat,
      index: index,
      highlight: chat.highlight,
      onHighlightEnd: () {
        if (chat.highlight) {
          setState(() {
            _chatList[index] = ChatItem(
              avatar: chat.avatar,
              name: chat.name,
              lastMessage: chat.lastMessage,
              time: chat.time,
              unread: chat.unread,
              isMuted: chat.isMuted,
              isPinned: chat.isPinned,
              isGroup: chat.isGroup,
              isDraft: chat.isDraft,
              isOnline: chat.isOnline,
              highlight: false,
            );
            _clearCache();
          });
        }
      },
      itemHeight: ChatListLayout.itemHeight,
      avatarSize: ChatListLayout.avatarSize,
      avatarGlow: ChatListLayout.avatarGlow,
      paddingV: ChatListLayout.paddingV,
      paddingH: ChatListLayout.paddingH,
      nameFont: ChatListLayout.nameFont,
      msgFont: ChatListLayout.msgFont,
      timeFont: ChatListLayout.timeFont,
      isDark: isDark,
      onDelete: () {
        setState(() {
          _chatList.removeAt(index);
          _clearCache();
        });
      },
      onTogglePin: () {
        setState(() {
          _chatList[index].isPinned = !chat.isPinned;
          _clearCache();
        });
      },
      onToggleMute: () {
        setState(() {
          _chatList[index].isMuted = !chat.isMuted;
        });
      },
    );
  }

  /// 分组标题组件
  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }
}

// ===================== 自定义画笔 =====================
/// 流光高亮边框画笔
class FlowingBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double borderWidth;
  final bool isDark;

  FlowingBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double r = borderRadius;
    final double w = size.width;
    final double h = size.height;
    final double bw = borderWidth;

    final path = Path();
    path.moveTo(r, h - bw / 2);
    path.lineTo(w - r, h - bw / 2);

    final double glowWidth = w * 0.32;
    final double startX = progress * (w - glowWidth - 2 * r) + r;
    final Rect glowRect = Rect.fromLTWH(startX, h - bw * 4, glowWidth, bw * 8);
    final Gradient gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.95),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final paint = Paint()
      ..shader = gradient.createShader(glowRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 3.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FlowingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.isDark != isDark;
  }
}

/// 静态边框画笔
class StaticBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final bool isDark;

  StaticBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = borderRadius;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect.deflate(borderWidth / 2), Radius.circular(r)));
    final paint = Paint()
      ..color = Colors.white.withOpacity(isDark ? 0.13 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StaticBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.isDark != isDark;
  }
}
