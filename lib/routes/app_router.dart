import 'package:blue_openflutter/pages/chat_list_theme_page.dart';
import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/settings_page.dart';
import '../pages/about_page.dart';
import '../pages/splash_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String msgList = '/msglist';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) {
      return _buildErrorRoute('路由名称为空');
    }

    if (name == splash) {
      return MaterialPageRoute(builder: (_) => const SplashPage());
    } else if (name == login) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    } else if (name == home) {
      return MaterialPageRoute(builder: (_) => const HomePage());
    } else if (name == AppRouter.settings) {
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    } else if (name == about) {
      return MaterialPageRoute(builder: (_) => const AboutPage());
    } else if (name == msgList) {
      return MaterialPageRoute(builder: (_) => const ChatListThemePage());
    } else {
      return _buildErrorRoute('没有找到路由: $name');
    }
  }

  static MaterialPageRoute _buildErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
