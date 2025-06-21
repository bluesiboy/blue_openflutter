import 'package:blue_openflutter/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

class ChatDetailPage extends StatefulWidget {
  final String userName;
  final String avatar;

  const ChatDetailPage({
    required this.userName,
    required this.avatar,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> with SingleTickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isEmojiVisible = false;
  bool _isMoreVisible = false;
  bool _isRecording = false;
  bool _isKeyboardVisible = false;
  late AnimationController _animationController;
  Duration _switchIconDuration = const Duration(milliseconds: 300);
  static Map<int, Size> _imageSizeCache = {}; // 用于缓存所有图片的尺寸
  Set<int> _loadingImageIndex = {}; // 正在加载的图片index

  final List<Message> messages = [
    Message(
      fromMe: false,
      type: 'text',
      content: '你好！最近在忙什么呢？',
      time: '09:30',
      status: 'read',
    ),
    Message(
      fromMe: true,
      type: 'text',
      content: '在开发一个新的聊天应用，功能很丰富，支持发送文本、图片、表情等',
      time: '09:31',
      status: 'read',
    ),
    Message(
      fromMe: false,
      type: 'image',
      content: 'assets/imgs/IMG_20241111_200606.jpg',
      time: '09:32',
      status: 'read',
    ),
    Message(
      fromMe: true,
      type: 'text',
      content: '看起来不错！这个界面设计得很漂亮',
      time: '09:33',
      status: 'sending',
    ),
    Message(
      fromMe: false,
      type: 'text',
      content: '是的，我们花了很多时间在UI/UX上，希望给用户最好的体验',
      time: '09:34',
      status: 'read',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
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
    setState(() {
      _switchIconDuration = const Duration(milliseconds: 300);
      // 触发重建以更新按钮状态
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // 获取当前时间
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      messages.add(
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
          messages.last.status = 'sent';
        });
      }
    });
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

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final platform = theme.platform;

    final isDesktop =
        platform == TargetPlatform.windows || platform == TargetPlatform.linux || platform == TargetPlatform.macOS;

    if (platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 实现搜索功能
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.search, size: 20),
                  SizedBox(width: 8),
                  Text('搜索聊天记录'),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 实现免打扰功能
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.bell_slash, size: 20),
                  SizedBox(width: 8),
                  Text('消息免打扰'),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                // TODO: 实现清空功能
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.delete, size: 20),
                  SizedBox(width: 8),
                  Text('清空聊天记录'),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ),
      );
    } else if (isDesktop) {
      final RenderBox? button = _menuKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
      if (button == null || overlay == null) return;

      final position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      showMenu(
        context: context,
        position: position,
        items: [
          PopupMenuItem(
            onTap: () {
              // TODO: 实现搜索功能
            },
            child: const Row(
              children: [
                Icon(Icons.search),
                SizedBox(width: 8),
                Text('搜索聊天记录'),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              // TODO: 实现免打扰功能
            },
            child: const Row(
              children: [
                Icon(Icons.notifications_off),
                SizedBox(width: 8),
                Text('消息免打扰'),
              ],
            ),
          ),
          PopupMenuItem(
            onTap: () {
              // TODO: 实现清空功能
            },
            child: Row(
              children: [
                Icon(Icons.delete, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text('清空聊天记录', style: TextStyle(color: theme.colorScheme.error)),
              ],
            ),
          ),
        ],
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('搜索聊天记录'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现搜索功能
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('消息免打扰'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现免打扰功能
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: theme.colorScheme.error),
                title: Text('清空聊天记录', style: TextStyle(color: theme.colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现清空功能
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircleAvatar(
            //   radius: 20,
            //   backgroundImage: AssetImage(widget.avatar),
            // ),
            // const SizedBox(width: 8),
            Text(widget.userName),
          ],
        ),
        actions: [
          IconButton(
            key: _menuKey,
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          setState(() {
            _isEmojiVisible = false;
            _isMoreVisible = false;
          });
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: msg.fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!msg.fromMe) ...[
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(widget.avatar),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: msg.fromMe ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(msg.fromMe ? 16 : 4),
                                    bottomRight: Radius.circular(msg.fromMe ? 4 : 16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.shadow.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: msg.type == 'text'
                                    ? Text(
                                        msg.content,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: msg.fromMe
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSurfaceVariant,
                                        ),
                                      )
                                    : _buildImageWidget(msg, index, theme),
                              ),
                              if (msg.fromMe)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (msg.status == 'sending')
                                        const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else if (msg.status == 'sent')
                                        const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.grey,
                                        )
                                      else if (msg.status == 'read')
                                        const Icon(
                                          Icons.done_all,
                                          size: 12,
                                          color: Colors.blue,
                                        ),
                                      const SizedBox(width: 4),
                                      Text(
                                        msg.time,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (msg.fromMe) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            radius: 16,
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildEmojiList(),
            _buildAddList(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiList() {
    // 定义表情列表
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRect(
        child: Column(
          children: [
            Expanded(
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
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
          ],
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
      {'icon': Icons.contact_phone, 'label': '联系人'},
      {'icon': Icons.schedule, 'label': '日程'},
      {'icon': Icons.payment, 'label': '转账'},
      {'icon': Icons.games, 'label': '游戏'},
    ];

    // 计算需要的行数
    final crossAxisCount = 4; // 每行4个项目
    final rowCount = (addItems.length / crossAxisCount).ceil();
    final itemHeight = 80.0; // 每个项目的高度
    final padding = 32.0; // 上下padding
    final spacing = 16.0 * (rowCount - 1); // 行间距
    final calculatedHeight = rowCount * itemHeight + padding + spacing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: _isMoreVisible ? calculatedHeight : 0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 键盘/语音切换按钮
            IconButton(
              icon: Icon(
                _isKeyboardVisible ? Icons.mic : Icons.keyboard,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _isKeyboardVisible = !_isKeyboardVisible;
                  _isEmojiVisible = false;
                  _isMoreVisible = false;
                  _switchIconDuration = Duration.zero;
                });
                if (_isKeyboardVisible) {
                  _focusNode.requestFocus();
                } else {
                  _focusNode.unfocus();
                }
              },
            ),
            // 输入框或语音按钮
            Expanded(
              child: _isKeyboardVisible
                  ? Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 36,
                          maxHeight: 120,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                            strutStyle: StrutStyle(
                              forceStrutHeight: true,
                              height: 1.0,
                              leading: 0.5,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: InputBorder.none,
                              isDense: true,
                              hintText: '输入消息...',
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                            onSubmitted: (text) {
                              if (text.trim().isNotEmpty) {
                                _sendMessage(text);
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onLongPressStart: (details) {
                        setState(() {
                          _isRecording = true;
                        });
                        // TODO: 开始录音
                      },
                      onLongPressEnd: (details) {
                        setState(() {
                          _isRecording = false;
                        });
                        // TODO: 结束录音
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 36,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary)
                                  .withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              _isRecording ? Icons.mic : Icons.mic_none,
                              size: 18,
                              color: _isRecording
                                  ? Theme.of(context).colorScheme.onErrorContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isRecording ? '松开发送' : '按住说话',
                              style: TextStyle(
                                color: _isRecording
                                    ? Theme.of(context).colorScheme.onErrorContainer
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            // 表情按钮
            IconButton(
              icon: Icon(
                _isEmojiVisible ? Icons.emoji_emotions : Icons.emoji_emotions_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _isEmojiVisible = !_isEmojiVisible;
                  _isMoreVisible = false;
                  _isKeyboardVisible = false;
                  _switchIconDuration = Duration.zero;
                });
                if (_isEmojiVisible) {
                  _focusNode.unfocus();
                }
              },
            ),
            // 加号按钮或发送按钮
            IconButton(
              icon: AnimatedSwitcher(
                duration: _switchIconDuration,
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  // 发送消息
                  _sendMessage(_controller.text);
                } else {
                  // 显示更多功能
                  setState(() {
                    _isMoreVisible = !_isMoreVisible;
                    _isEmojiVisible = false;
                    _isKeyboardVisible = false;
                    _switchIconDuration = Duration.zero;
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
    );
  }

  Widget _buildImageWidget(Message msg, int index, ThemeData theme) {
    final isAsset = msg.content.startsWith('assets/');
    final double maxWidth = 200, maxHeight = 200;
    double? imgWidth = msg.width;
    double? imgHeight = msg.height;
    Size? cachedSize = _imageSizeCache[index];

    // 优先用消息对象的宽高
    if ((imgWidth == null || imgHeight == null) && cachedSize != null) {
      imgWidth = cachedSize.width;
      imgHeight = cachedSize.height;
    }

    // 如果都没有，则异步获取
    if ((imgWidth == null || imgHeight == null) && !_loadingImageIndex.contains(index)) {
      _loadingImageIndex.add(index);
      _getImageSize(msg, index, isAsset);
    }

    // loading 效果
    if (imgWidth == null || imgHeight == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: maxWidth,
          height: maxHeight,
          color: theme.colorScheme.surfaceVariant,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // 缩放
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
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imgWidth,
                height: imgHeight,
                color: theme.colorScheme.surfaceVariant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.onSurfaceVariant, size: 32),
                    const SizedBox(height: 8),
                    Text('图片加载失败', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              );
            },
          )
        : Image.network(
            msg.content,
            width: imgWidth,
            height: imgHeight,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imgWidth,
                height: imgHeight,
                color: theme.colorScheme.surfaceVariant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.onSurfaceVariant, size: 32),
                    const SizedBox(height: 8),
                    Text('图片加载失败', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              );
            },
          );
    return GestureDetector(
      onTap: () {
        _showImageDialog(context, msg, imgWidth!, imgHeight!, isAsset, index);
      },
      child: Hero(
        tag: 'chat_image_$index',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: imageWidget,
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, Message msg, double width, double height, bool isAsset, int index) {
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
              _imageSizeCache[index] = const Size(200, 200); // 加载失败给默认
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
