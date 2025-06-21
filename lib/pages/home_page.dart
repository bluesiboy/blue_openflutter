import 'package:blue_openflutter/controls/breath_glow_widget.dart';
import 'package:blue_openflutter/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'chat_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const _HomeTab(),
    const _ExploreTab(),
    const _MessageTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          selectedIcon: Icon(
            Icons.home,
            color: theme.colorScheme.primary,
          ),
          label: '首页',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.explore_outlined,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          selectedIcon: Icon(
            Icons.explore,
            color: theme.colorScheme.primary,
          ),
          label: '发现',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.message_outlined,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          selectedIcon: Icon(
            Icons.message,
            color: theme.colorScheme.primary,
          ),
          label: '消息',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          selectedIcon: Icon(
            Icons.person,
            color: theme.colorScheme.primary,
          ),
          label: '我的',
        ),
      ],
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSearching) {
          setState(() => _isSearching = false);
          _searchController.clear();
          FocusScope.of(context).unfocus();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          if (_isSearching) {
            setState(() => _isSearching = false);
            _searchController.clear();
            FocusScope.of(context).unfocus();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              title: const Text('首页'),
              actions: [
                _buildSearchBox(context),
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined),
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: _showNotificationPanel,
                ),
                const SizedBox(width: 10),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Text('轮播图区域'),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('功能卡片 ${index + 1}'),
                    ),
                  ),
                  childCount: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSearching ? MediaQuery.of(context).size.width * 0.5 : 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: _isSearching
            ? Border(
                bottom: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          if (_isSearching) ...[
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '搜索',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onSubmitted: (value) {
                  if (value.isEmpty) {
                    setState(() => _isSearching = false);
                    _searchController.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() => _isSearching = false);
                _searchController.clear();
              },
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => _isSearching = true);
              },
            ),
        ],
      ),
    );
  }

  void _showNotificationPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationHeader(context),
              Expanded(
                child: _buildNotificationList(context, scrollController),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '通知',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现查看全部功能
            },
            child: Text(
              '查看全部',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, ScrollController scrollController) {
    final theme = Theme.of(context);
    final notifications = [
      {
        'title': '系统通知',
        'content': '您的账号已成功登录',
        'time': '刚刚',
        'isRead': false,
      },
      {
        'title': '待办提醒',
        'content': '您有3个待办事项需要处理',
        'time': '10分钟前',
        'isRead': false,
      },
      {
        'title': '消息通知',
        'content': '张三给您发送了一条新消息',
        'time': '30分钟前',
        'isRead': true,
      },
    ];

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isRead = notification['isRead'] as bool;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  notification['title'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                notification['time'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              notification['content'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            // TODO: 处理通知点击
          },
        );
      },
    );
  }
}

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('发现页面'),
    );
  }
}

class _MessageTab extends StatelessWidget {
  const _MessageTab();

  @override
  Widget build(BuildContext context) {
    return const ChatListPage();
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late final BreathGlowController _breathGlowController2;
  @override
  void initState() {
    super.initState();
    _breathGlowController2 = BreathGlowController(
      breathCount: 14,
      duration: const Duration(seconds: 1),
      maxOpacity: 0.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          title: const Text('个人中心'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.settings);
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildUserInfo(context),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 16),
              _buildMenuList(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BreathGlowWidget(
                  controller: _breathGlowController2,
                  glowColor: theme.colorScheme.primary,
                  child: Text(
                    '用户名',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: 12345678',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                BreathGlowWidget(
                  controller: _breathGlowController2,
                  glowColor: theme.colorScheme.primary,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: 编辑个人资料
                      _breathGlowController2.start();
                    },
                    child: const Text('编辑资料'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final actions = <Map<String, dynamic>>[
      {'icon': Icons.favorite_border, 'label': '收藏', 'count': '12'},
      {'icon': Icons.history, 'label': '历史', 'count': '23'},
      {'icon': Icons.star_border, 'label': '关注', 'count': '45'},
      {'icon': Icons.download_outlined, 'label': '下载', 'count': '8'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action['count']!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action['label']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final theme = Theme.of(context);
    final menuItems = <Map<String, dynamic>>[
      {
        'icon': Icons.payment_outlined,
        'label': '我的钱包',
        'trailing': '¥ 1,234.56',
      },
      {
        'icon': Icons.card_giftcard_outlined,
        'label': '我的订单',
        'trailing': '查看全部订单',
      },
      {
        'icon': Icons.location_on_outlined,
        'label': '收货地址',
        'trailing': '管理收货地址',
      },
      {
        'icon': Icons.support_agent_outlined,
        'label': '客服中心',
        'trailing': '在线客服',
      },
      {
        'icon': Icons.help_outline,
        'label': '帮助中心',
        'trailing': '常见问题',
      },
      {
        'icon': Icons.info_outline,
        'label': '关于我们',
        'trailing': '版本 1.0.0',
        'route': AppRouter.about,
      },
    ];

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: menuItems.map((item) {
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: theme.colorScheme.primary,
            ),
            title: Text(item['label']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item['trailing'] != null)
                  Text(
                    item['trailing']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
            onTap: () {
              if (item.containsKey('route')) Navigator.pushNamed(context, item['route']);
            },
          );
        }).toList(),
      ),
    );
  }
}
