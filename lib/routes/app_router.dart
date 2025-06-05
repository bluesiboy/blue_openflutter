import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/device_demo_page.dart';
import '../pages/settings_page.dart';
import '../pages/login_page.dart';
import '../pages/theme_style_config_page.dart';

class AppRouter {
  static const String home = '/';
  static const String deviceDemo = '/device';
  static const String settingDemo = '/setting';
  static const String themeStyleDemo = 'themestyleconfig';
  static const String login = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case deviceDemo:
        return MaterialPageRoute(builder: (_) => const DeviceDemoPage());
      case settingDemo:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case themeStyleDemo:
        return MaterialPageRoute(builder: (_) => const ThemeStyleConfigPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('没有找到路由: ${settings.name}'))),
        );
    }
  }
}
