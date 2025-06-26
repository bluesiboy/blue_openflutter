import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/message_model.dart';
import 'dart:ui';

// ===================== 详情页布局参数 =====================
class ChatDetailLayout {
  /// 消息气泡最大宽度
  static const double maxBubbleWidth = 280;

  /// 消息气泡内边距
  static const double bubblePadding = 8;

  /// 消息气泡圆角
  static const double bubbleRadius = 20;

  /// 头像尺寸
  static const double avatarSize = 36;

  /// 消息间距
  static const double messageSpacing = 8;

  /// 输入框高度
  static const double inputHeight = 38;

  /// 输入框圆角
  static const double inputRadius = 24;

  /// 毛玻璃模糊度
  static const double blurAmount = 18;

  /// 边框宽度
  static const double borderWidth = 1.0;

  /// 输入框内边距
  static const double inputPadding = 8;

  /// 输入框水平内边距
  static const double inputHorizontalPadding = 16;

  /// 输入框垂直内边距
  static const double inputVerticalPadding = 12;

  /// 消息状态图标大小
  static const double statusIconSize = 14;

  /// 消息时间字体大小
  static const double timeFontSize = 11;

  /// 消息文本字体大小
  static const double messageFontSize = 15;

  /// 输入框文本字体大小
  static const double inputFontSize = 14;
}

// ===================== 格式化时间工具 =====================
String formatTime12Hour(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
  return "$hour:$minute $ampm";
}

// ===================== 聊天详情页 =====================
class ChatDetailPage extends StatefulWidget {
  final String userName;
  final String avatar;
  final bool isGroup;
  final bool isOnline;

  const ChatDetailPage({
    required this.userName,
    required this.avatar,
    this.isGroup = false,
    this.isOnline = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isEmojiVisible = false;
  bool _isMoreVisible = false;
  bool _isRecording = false;
  bool _isKeyboardVisible = false;
  bool _showScrollToBottom = false;

  late AnimationController _animationController;
  late AnimationController _typingController;

  // 消息列表
  List<Message> _messages = [];

  // 图片尺寸缓存
  static Map<int, Size> _imageSizeCache = {};
  Set<int> _loadingImageIndex = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
    _scrollController.addListener(_onScroll);

    _loadInitialMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _isEmojiVisible = false;
        _isMoreVisible = false;
      });
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onScroll() {
    final showButton = _scrollController.offset < _scrollController.position.maxScrollExtent - 200;
    if (showButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showButton;
      });
    }
  }

  void _loadInitialMessages() {
    // 生成初始消息
    final now = DateTime.now();
    _messages = [
      Message(
        fromMe: false,
        type: 'text',
        content: '你好！最近在忙什么呢？',
        time: formatTime12Hour(now.subtract(const Duration(minutes: 5))),
        status: 'read',
      ),
      Message(
        fromMe: true,
        type: 'text',
        content: '在开发一个新的聊天应用，功能很丰富，支持发送文本、图片、表情等',
        time: formatTime12Hour(now.subtract(const Duration(minutes: 4))),
        status: 'read',
      ),
      Message(
        fromMe: false,
        type: 'image',
        content: 'assets/imgs/IMG_20241111_200606.jpg',
        time: formatTime12Hour(now.subtract(const Duration(minutes: 3))),
        status: 'read',
      ),
      Message(
        fromMe: true,
        type: 'text',
        content: '看起来不错！这个界面设计得很漂亮',
        time: formatTime12Hour(now.subtract(const Duration(minutes: 2))),
        status: 'sent',
      ),
      Message(
        fromMe: false,
        type: 'text',
        content: '是的，我们花了很多时间在UI/UX上，希望给用户最好的体验',
        time: formatTime12Hour(now.subtract(const Duration(minutes: 1))),
        status: 'read',
      ),
    ];
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final timeString = formatTime12Hour(now);

    setState(() {
      _messages.add(
        Message(
          fromMe: true,
          type: 'text',
          content: text,
          time: timeString,
          status: 'sending',
        ),
      );
    });
    _controller.clear();
    _scrollToBottom();

    // 模拟发送状态
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.last.status = 'sent';
        });
      }
    });

    // 模拟对方回复
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _addReplyMessage();
      }
    });
  }

  void _addReplyMessage() {
    final replies = [
      '收到！',
      '好的，我知道了',
      '嗯嗯，明白了',
      '不错不错',
      '继续加油！',
      '这个想法很棒',
      '我同意你的观点',
      '确实如此',
    ];

    final random = Random();
    final reply = replies[random.nextInt(replies.length)];
    final now = DateTime.now();

    setState(() {
      _messages.add(
        Message(
          fromMe: false,
          type: 'text',
          content: reply,
          time: formatTime12Hour(now),
          status: 'read',
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDark),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildMessageList(isDark),
                ),
                _buildEmojiList(),
                _buildAddList(),
                _buildInputBar(isDark),
              ],
            ),
          ),
          // 滚动到底部按钮
          if (_showScrollToBottom)
            Positioned(
              right: 20,
              bottom: 100,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blueAccent.withOpacity(0.9),
                foregroundColor: Colors.white,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.keyboard_arrow_down),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 300.ms),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.blueGrey.withOpacity(0.28) : Colors.blueAccent.withOpacity(0.18),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              ClipOval(
                child: Image.asset(
                  widget.avatar,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stack) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.white54, size: 24),
                  ),
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (widget.isOnline)
                  Text(
                    '在线',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.video_call,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.call,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => _showOptionsMenu(),
        ),
      ],
    );
  }

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

  Widget _buildMessageList(bool isDark) {
    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 400),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: _buildMessageItem(msg, index, isDark),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(Message msg, int index, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ChatDetailLayout.messageSpacing / 2),
      child: Row(
        mainAxisAlignment: msg.fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.fromMe) ...[
            Stack(
              children: [
                Container(
                  width: ChatDetailLayout.avatarSize,
                  height: ChatDetailLayout.avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.blueGrey.withValues(alpha: 70) : Colors.blueAccent.withValues(alpha: 45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                ClipOval(
                  child: Image.asset(
                    widget.avatar,
                    width: ChatDetailLayout.avatarSize,
                    height: ChatDetailLayout.avatarSize,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stack) => Container(
                      width: ChatDetailLayout.avatarSize,
                      height: ChatDetailLayout.avatarSize,
                      color: Colors.grey[300],
                      child: Icon(Icons.person, color: Colors.white54, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(msg, index, isDark),
                const SizedBox(height: 4),
                if (msg.fromMe) _buildMessageStatus(msg, isDark),
              ],
            ),
          ),
          if (msg.fromMe) ...[
            const SizedBox(width: 8),
            Container(
              width: ChatDetailLayout.avatarSize,
              height: ChatDetailLayout.avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.blueGrey.withValues(alpha: 80) : Colors.blueAccent.withValues(alpha: 25),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.blueGrey.withValues(alpha: 40) : Colors.blueAccent.withValues(alpha: 20),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 20,
                color: isDark ? Colors.white70 : Colors.blueAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, int index, bool isDark) {
    Widget bubbleContent;
    if (msg.type == 'text') {
      bubbleContent = Text(
        msg.content,
        style: TextStyle(
          fontSize: ChatDetailLayout.messageFontSize,
          color: msg.fromMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.start,
      );
    } else if (msg.type == 'emoji') {
      bubbleContent = Text(
        msg.content,
        style: TextStyle(
          fontSize: 36,
          color: msg.fromMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
        ),
        textAlign: TextAlign.center,
      );
    } else if (msg.type == 'file') {
      bubbleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, color: msg.fromMe ? Colors.white : Colors.blueAccent, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              msg.content,
              style: TextStyle(
                fontSize: ChatDetailLayout.messageFontSize,
                color: msg.fromMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (msg.type == 'voice') {
      bubbleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_voice, color: msg.fromMe ? Colors.white : Colors.blueAccent, size: 22),
          const SizedBox(width: 8),
          Text(
            msg.content, // 语音时长
            style: TextStyle(
              fontSize: ChatDetailLayout.messageFontSize,
              color: msg.fromMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      );
    } else if (msg.type == 'image') {
      // 图片消息直接显示，不使用气泡
      return _buildImageWidget(msg, index, isDark);
    } else {
      bubbleContent = Text(
        msg.content,
        style: TextStyle(
          fontSize: ChatDetailLayout.messageFontSize,
          color: msg.fromMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: ChatDetailLayout.maxBubbleWidth, minWidth: 60),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ChatDetailLayout.bubbleRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: ChatDetailLayout.blurAmount, sigmaY: ChatDetailLayout.blurAmount),
          child: Container(
            padding: EdgeInsets.all(ChatDetailLayout.bubblePadding),
            decoration: BoxDecoration(
              color: msg.fromMe
                  ? Colors.blueAccent.withOpacity(isDark ? 0.10 : 0.13)
                  : Colors.white.withOpacity(isDark ? 0.08 : 0.10),
              border: Border.all(
                color:
                    msg.fromMe ? Colors.blueAccent.withOpacity(0.18) : Colors.white.withOpacity(isDark ? 0.13 : 0.18),
                width: ChatDetailLayout.borderWidth,
              ),
              borderRadius: BorderRadius.circular(ChatDetailLayout.bubbleRadius),
            ),
            child: bubbleContent,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatus(Message msg, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (msg.status == 'sending')
          SizedBox(
            width: ChatDetailLayout.statusIconSize,
            height: ChatDetailLayout.statusIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.white54 : Colors.grey,
              ),
            ),
          )
        else if (msg.status == 'sent')
          Icon(
            Icons.check,
            size: ChatDetailLayout.statusIconSize,
            color: isDark ? Colors.white54 : Colors.grey,
          )
        else if (msg.status == 'read')
          Icon(
            Icons.done_all,
            size: ChatDetailLayout.statusIconSize,
            color: Colors.blueAccent,
          ),
        const SizedBox(width: 6),
        Text(
          msg.time,
          style: TextStyle(
            fontSize: ChatDetailLayout.timeFontSize,
            color: isDark ? Colors.white38 : Colors.black38,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(Message msg, int index, bool isDark) {
    final isAsset = msg.content.startsWith('assets/');
    final double maxWidth = 200, maxHeight = 200;
    double? imgWidth = msg.width;
    double? imgHeight = msg.height;
    Size? cachedSize = _imageSizeCache[index];

    if ((imgWidth == null || imgHeight == null) && cachedSize != null) {
      imgWidth = cachedSize.width;
      imgHeight = cachedSize.height;
    }

    if ((imgWidth == null || imgHeight == null) && !_loadingImageIndex.contains(index)) {
      _loadingImageIndex.add(index);
      _getImageSize(msg, index, isAsset);
    }

    if (imgWidth == null || imgHeight == null) {
      return Container(
        width: maxWidth,
        height: maxHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 5),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    double scale = (imgWidth > maxWidth || imgHeight > maxHeight)
        ? (imgWidth / maxWidth > imgHeight / maxHeight ? maxWidth / imgWidth : maxHeight / imgHeight)
        : 1.0;
    imgWidth = imgWidth * scale;
    imgHeight = imgHeight * scale;

    final imageWidget = isAsset
        ? Image.asset(
            msg.content,
            width: imgWidth,
            height: imgHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imgWidth,
                height: imgHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: isDark ? Colors.white54 : Colors.grey, size: 32),
                    const SizedBox(height: 8),
                    Text('图片加载失败', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            },
          )
        : Image.network(
            msg.content,
            width: imgWidth,
            height: imgHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imgWidth,
                height: imgHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: isDark ? Colors.white54 : Colors.grey, size: 32),
                    const SizedBox(height: 8),
                    Text('图片加载失败', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            },
          );

    return GestureDetector(
      onTap: () => _showImageDialog(msg, imgWidth!, imgHeight!, isAsset, index),
      child: Hero(
        tag: 'chat_image_$index',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 8),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiList() {
    final emojis = [
      '😊',
      '😂',
      '🤣',
      '❤️',
      '😍',
      '😘',
      '😋',
      '😎',
      '🤔',
      '😭',
      '😡',
      '😱',
      '😴',
      '🤗',
      '🤫',
      '🤐',
      '😶',
      '😐',
      '😑',
      '😯',
      '😦',
      '😧',
      '😮',
      '😲'
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: _isEmojiVisible ? 240 : 0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: ClipRect(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: emojis.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _sendMessage(emojis[index]);
                setState(() {
                  _isEmojiVisible = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddList() {
    final addItems = [
      {'icon': Icons.photo, 'label': '照片'},
      {'icon': Icons.videocam, 'label': '视频'},
      {'icon': Icons.location_on, 'label': '位置'},
      {'icon': Icons.phone, 'label': '语音通话'},
      {'icon': Icons.video_call, 'label': '视频通话'},
      {'icon': Icons.file_copy, 'label': '文件'},
      {'icon': Icons.camera_alt, 'label': '拍摄'},
      {'icon': Icons.record_voice_over, 'label': '录音'},
    ];

    final crossAxisCount = 4;
    final rowCount = (addItems.length / crossAxisCount).ceil();
    final itemHeight = 80.0;
    final padding = 32.0;
    final spacing = 16.0 * (rowCount - 1);
    final calculatedHeight = rowCount * itemHeight + padding + spacing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: _isMoreVisible ? calculatedHeight : 0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: ClipRect(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: addItems.length,
          itemBuilder: (context, index) {
            final item = addItems[index];
            return GestureDetector(
              onTap: () {
                // TODO: 处理功能点击
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label']! as String,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: ChatDetailLayout.inputHeight + 16,
      borderRadius: 0,
      blur: ChatDetailLayout.blurAmount,
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(isDark ? 0.1 : 0.2),
          Colors.white.withOpacity(isDark ? 0.05 : 0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(isDark ? 0.1 : 0.2),
          Colors.white.withOpacity(isDark ? 0.05 : 0.1),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ChatDetailLayout.inputHorizontalPadding,
            vertical: ChatDetailLayout.inputPadding,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isKeyboardVisible ? Icons.mic : Icons.keyboard,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  setState(() {
                    _isKeyboardVisible = !_isKeyboardVisible;
                    _isEmojiVisible = false;
                    _isMoreVisible = false;
                  });
                  if (_isKeyboardVisible) {
                    _focusNode.requestFocus();
                  } else {
                    _focusNode.unfocus();
                  }
                },
              ),
              Expanded(
                child: _isKeyboardVisible
                    ? Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(ChatDetailLayout.inputRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          style: TextStyle(
                            fontSize: ChatDetailLayout.inputFontSize,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ChatDetailLayout.inputHorizontalPadding,
                              vertical: ChatDetailLayout.inputVerticalPadding,
                            ),
                            border: InputBorder.none,
                            hintText: '输入消息...',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: ChatDetailLayout.inputFontSize,
                            ),
                          ),
                          onSubmitted: (text) {
                            if (text.trim().isNotEmpty) {
                              _sendMessage(text);
                            }
                          },
                        ),
                      )
                    : GestureDetector(
                        onLongPressStart: (details) {
                          setState(() {
                            _isRecording = true;
                          });
                        },
                        onLongPressEnd: (details) {
                          setState(() {
                            _isRecording = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: ChatDetailLayout.inputHeight,
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? Colors.red.withOpacity(0.2)
                                : (isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8)),
                            borderRadius: BorderRadius.circular(ChatDetailLayout.inputRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isRecording ? Icons.mic : Icons.mic_none,
                                size: 18,
                                color: _isRecording ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isRecording ? '松开发送' : '按住说话',
                                style: TextStyle(
                                  color: _isRecording ? Colors.red : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: ChatDetailLayout.inputFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              IconButton(
                icon: Icon(
                  _isEmojiVisible ? Icons.emoji_emotions : Icons.emoji_emotions_outlined,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  setState(() {
                    _isEmojiVisible = !_isEmojiVisible;
                    _isMoreVisible = false;
                    _isKeyboardVisible = false;
                  });
                  if (_isEmojiVisible) {
                    _focusNode.unfocus();
                  }
                },
              ),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    _controller.text.trim().isNotEmpty
                        ? Icons.send
                        : (_isMoreVisible ? Icons.add_circle : Icons.add_circle_outline),
                    key: ValueKey(
                      _controller.text.trim().isNotEmpty ? 'send' : (_isMoreVisible ? 'add_solid' : 'add_outline'),
                    ),
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    _sendMessage(_controller.text);
                  } else {
                    setState(() {
                      _isMoreVisible = !_isMoreVisible;
                      _isEmojiVisible = false;
                      _isKeyboardVisible = false;
                    });
                    if (_isMoreVisible) {
                      _focusNode.unfocus();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('搜索聊天记录'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('消息免打扰'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('清空聊天记录', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(Message msg, double width, double height, bool isAsset, int index) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.85),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Hero(
                  tag: 'chat_image_$index',
                  child: isAsset
                      ? Image.asset(
                          msg.content,
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          msg.content,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ));
  }

  void _getImageSize(Message msg, int index, bool isAsset) async {
    try {
      if (isAsset) {
        final data = await rootBundle.load(msg.content);
        final bytes = data.buffer.asUint8List();
        ui.decodeImageFromList(bytes, (ui.Image image) {
          if (mounted) {
            setState(() {
              _imageSizeCache[index] = Size(image.width.toDouble(), image.height.toDouble());
              _loadingImageIndex.remove(index);
            });
          }
        });
      } else {
        final imageProvider = NetworkImage(msg.content);
        final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
        late ImageStreamListener listener;
        listener = ImageStreamListener((ImageInfo info, bool _) {
          if (mounted) {
            setState(() {
              _imageSizeCache[index] = Size(info.image.width.toDouble(), info.image.height.toDouble());
              _loadingImageIndex.remove(index);
            });
          }
          stream.removeListener(listener);
        }, onError: (dynamic _, __) {
          if (mounted) {
            setState(() {
              _imageSizeCache[index] = const Size(200, 200);
              _loadingImageIndex.remove(index);
            });
          }
          stream.removeListener(listener);
        });
        stream.addListener(listener);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _imageSizeCache[index] = const Size(200, 200);
          _loadingImageIndex.remove(index);
        });
      }
    }
  }
}
