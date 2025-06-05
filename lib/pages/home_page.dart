import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import '../routes/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await MoveToBackground.moveTaskToBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter 示例'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, AppRouter.settingDemo),
            ),
          ],
        ),
        body: ListView(
          children: [
            ListTile(title: const Text('登录页面示例'), onTap: () => Navigator.pushNamed(context, AppRouter.login)),
            ListTile(title: const Text('主题配置示例'), onTap: () => Navigator.pushNamed(context, AppRouter.themeStyleDemo)),
            ListTile(title: const Text('设备信息示例'), onTap: () => Navigator.pushNamed(context, AppRouter.deviceDemo)),
          ],
        ),
      ),
    );
  }
}
