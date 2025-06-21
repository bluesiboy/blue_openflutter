import 'package:blue_openflutter/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with SingleTickerProviderStateMixin {
  final GlobalKey _addMenuKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  final List<Chat> chats = [
    Chat(
      avatar: 'assets/avatar/0b204084df05411586e564eb051bb4d5.jpg',
      name: '张三',
      lastMessage: '你好，最近怎么样？',
      time: '09:30',
      unread: 2,
      isPinned: true,
    ),
    Chat(
      avatar: 'assets/avatar/0e04c08753f28c3eb4f81582d46cb12e.jpg',
      name: '李四',
      lastMessage: '[图片]',
      time: '昨天',
      unread: 0,
      isMuted: true,
    ),
    Chat(
      avatar: 'assets/avatar/1b4ed21f96972b08bd0ceb354794080e.jpg',
      name: '产品群',
      lastMessage: '王五: 新版本已经发布',
      time: '昨天',
      unread: 5,
      isPinned: true,
    ),
    Chat(
      avatar: 'assets/avatar/1bc858f2b28a8d47e7f8b52b2609d0ac.jpg',
      name: '技术交流群',
      lastMessage: '李四: 有人遇到这个问题吗？',
      time: '周一',
      unread: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddMenu(BuildContext context) {
    final theme = Theme.of(context);
    final platform = theme.platform;
    final isDesktop =
        platform == TargetPlatform.windows || platform == TargetPlatform.linux || platform == TargetPlatform.macOS;

    final actions = [
      {'icon': CupertinoIcons.group_solid, 'text': '发起群聊', 'onPressed': () {}},
      {'icon': CupertinoIcons.person_add_solid, 'text': '添加朋友', 'onPressed': () {}},
      {'icon': CupertinoIcons.qrcode_viewfinder, 'text': '扫一扫', 'onPressed': () {}},
    ];

    if (platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: actions
              .map((action) => CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      action['onPressed'] as Function();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action['icon'] as IconData, size: 20),
                        const SizedBox(width: 8),
                        Text(action['text'] as String),
                      ],
                    ),
                  ))
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ),
      );
    } else if (isDesktop) {
      final RenderBox? button = _addMenuKey.currentContext?.findRenderObject() as RenderBox?;
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
        items: actions
            .map((action) => PopupMenuItem(
                  onTap: action['onPressed'] as Function(),
                  child: Row(
                    children: [
                      Icon(action['icon'] as IconData, size: 20),
                      const SizedBox(width: 8),
                      Text(action['text'] as String),
                    ],
                  ),
                ))
            .toList(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: actions
                .map((action) => ListTile(
                      leading: Icon(action['icon'] as IconData, size: 20),
                      title: Text(action['text'] as String),
                      onTap: () {
                        Navigator.pop(context);
                        action['onPressed'] as Function();
                      },
                    ))
                .toList(),
          ),
        ),
      );
    }
  }

  void _showChatItemMenu(BuildContext context, int index, Offset? tapPosition) {
    final theme = Theme.of(context);
    final platform = theme.platform;
    final isDesktop =
        platform == TargetPlatform.windows || platform == TargetPlatform.linux || platform == TargetPlatform.macOS;
    final chat = chats[index];

    final actions = [
      {
        'icon': chat.isMuted ? CupertinoIcons.bell_slash : CupertinoIcons.bell,
        'text': chat.isMuted ? '取消免打扰' : '消息免打扰',
        'onPressed': () {
          setState(() {
            chat.isMuted = !chat.isMuted;
          });
        },
        'isDestructive': false
      },
      {
        'icon': chat.isPinned ? CupertinoIcons.pin_slash : CupertinoIcons.pin,
        'text': chat.isPinned ? '取消置顶' : '置顶聊天',
        'onPressed': () {
          setState(() {
            chat.isPinned = !chat.isPinned;
            chats.sort((a, b) {
              if (a.isPinned == b.isPinned) return 0;
              return a.isPinned ? -1 : 1;
            });
          });
        },
        'isDestructive': false
      },
      {
        'icon': CupertinoIcons.delete,
        'text': '删除聊天',
        'onPressed': () => setState(() => chats.removeAt(index)),
        'isDestructive': true
      },
    ];

    if (platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: actions
              .map((action) => CupertinoActionSheetAction(
                    isDestructiveAction: action['isDestructive'] as bool,
                    onPressed: () {
                      Navigator.pop(context);
                      (action['onPressed'] as Function)();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action['icon'] as IconData, size: 20),
                        const SizedBox(width: 8),
                        Text(action['text'] as String),
                      ],
                    ),
                  ))
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ),
      );
    } else if (isDesktop && tapPosition != null) {
      final position = RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        MediaQuery.of(context).size.width - tapPosition.dx,
        MediaQuery.of(context).size.height - tapPosition.dy,
      );
      showMenu(
        context: context,
        position: position,
        items: actions
            .map((action) => PopupMenuItem(
                  onTap: action['onPressed'] as Function(),
                  child: Row(
                    children: [
                      Icon(action['icon'] as IconData,
                          size: 20, color: (action['isDestructive'] as bool) ? theme.colorScheme.error : null),
                      const SizedBox(width: 8),
                      Text(action['text'] as String,
                          style: TextStyle(color: (action['isDestructive'] as bool) ? theme.colorScheme.error : null)),
                    ],
                  ),
                ))
            .toList(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: actions
                .map((action) => ListTile(
                      leading: Icon(action['icon'] as IconData,
                          size: 20, color: (action['isDestructive'] as bool) ? theme.colorScheme.error : null),
                      title: Text(action['text'] as String,
                          style: TextStyle(color: (action['isDestructive'] as bool) ? theme.colorScheme.error : null)),
                      onTap: () {
                        Navigator.pop(context);
                        (action['onPressed'] as Function)();
                      },
                    ))
                .toList(),
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.titleMedium,
                decoration: InputDecoration(
                  hintText: '搜索',
                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  // TODO: 实现搜索逻辑
                },
              )
            : const Text('消息'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => _isSearching = true);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            ),
          if (!_isSearching)
            IconButton(
              key: _addMenuKey,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                _showAddMenu(context);
              },
            ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            setState(() => _isSearching = false);
            return false;
          }
          return true;
        },
        child: ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final chat = chats[index];
            final theme = Theme.of(context);
            final platform = theme.platform;
            final isDesktop = platform == TargetPlatform.windows ||
                platform == TargetPlatform.linux ||
                platform == TargetPlatform.macOS;
            return Dismissible(
              key: Key(chat.name),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {
                  chats.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除 ${chat.name}'),
                    action: SnackBarAction(
                      label: '撤销',
                      onPressed: () {
                        setState(() {
                          chats.insert(index, chat);
                        });
                      },
                    ),
                  ),
                );
              },
              child: GestureDetector(
                onLongPressStart:
                    isDesktop ? null : (details) => _showChatItemMenu(context, index, details.globalPosition),
                onSecondaryTapUp:
                    isDesktop ? (details) => _showChatItemMenu(context, index, details.globalPosition) : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(chat.avatar),
                        // backgroundImage: NetworkImage(chat['avatar']),
                      ),
                      if (chat.isPinned)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.push_pin,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        chat.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      if (chat.isMuted)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.volume_off,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      if (chat.unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chat.unread}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                          key: ValueKey(chat.name),
                          userName: chat.name,
                          avatar: chat.avatar,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
