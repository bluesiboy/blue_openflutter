import 'package:blue_openflutter/providers/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'providers/theme_style_provider.dart';
import 'models/theme_style_config.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载保存的主题模式
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // 加载主题样式配置
  final themeStyleConfig = await ThemeStyleConfig.load();
  var userProfileProvider = await UserProfileProvider.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeStyleProvider(themeStyleConfig)),
        ChangeNotifierProvider(create: (_) => userProfileProvider),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  ThemeData _buildLightTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      ),
    );
  }

  ThemeData _buildDarkTheme(Color primaryColor, bool usePureBlack) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        onSurface: usePureBlack ? Colors.black : null,
        surface: usePureBlack ? Colors.black : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeStyleProvider>(
      builder: (context, themeProvider, _) {
        final config = themeProvider.config;
        final primaryColor = config.customPrimaryColor ?? Colors.blue;
        final usePureBlack = config.usePureBlack;

        return AdaptiveTheme(
          light: _buildLightTheme(primaryColor),
          dark: _buildDarkTheme(primaryColor, usePureBlack),
          initial: savedThemeMode ?? AdaptiveThemeMode.system,
          builder: (theme, darkTheme) {
            // 使用新的 MaterialApp 配置
            return MaterialApp(
              title: 'Flutter Demo',
              theme: theme,
              darkTheme: darkTheme,
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) {
                if (config.enableAnimation) {
                  return AnimatedTheme(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    data: Theme.of(context),
                    child: FlutterSmartDialog.init()(context, child),
                  );
                }
                return FlutterSmartDialog.init()(context, child);
              },
            );
          },
        );
      },
    );
  }
}
