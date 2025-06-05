import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStyleConfig {
  static const String _prefsKey = 'theme_style_config';

  // 主题样式类型
  static const String material = 'material';
  static const String ios = 'ios';
  static const String switch_ = 'switch';
  static const String segmented = 'segmented';
  static const String slider = 'slider';
  static const String preview = 'preview';
  static const String card3d = 'card3d';
  static const String animated = 'animated';
  static const String glass = 'glass';
  static const String neon = 'neon';
  static const String liquid = 'liquid';

  // 当前使用的主题样式
  String currentStyle;

  // 是否启用纯黑背景
  bool usePureBlack;

  // 是否启用动画效果
  bool enableAnimation;

  // 是否启用自定义颜色
  bool enableCustomColor;

  // 自定义主题色
  Color? customPrimaryColor;
  Color? customSecondaryColor;

  ThemeStyleConfig({
    this.currentStyle = material,
    this.usePureBlack = false,
    this.enableAnimation = true,
    this.enableCustomColor = false,
    this.customPrimaryColor,
    this.customSecondaryColor,
  });

  // 从JSON创建配置
  factory ThemeStyleConfig.fromJson(Map<String, dynamic> json) {
    return ThemeStyleConfig(
      currentStyle: json['currentStyle'] as String? ?? material,
      usePureBlack: json['usePureBlack'] as bool? ?? false,
      enableAnimation: json['enableAnimation'] as bool? ?? true,
      enableCustomColor: json['enableCustomColor'] as bool? ?? false,
      customPrimaryColor: json['customPrimaryColor'] != null ? Color(json['customPrimaryColor'] as int) : null,
      customSecondaryColor: json['customSecondaryColor'] != null ? Color(json['customSecondaryColor'] as int) : null,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'currentStyle': currentStyle,
      'usePureBlack': usePureBlack,
      'enableAnimation': enableAnimation,
      'enableCustomColor': enableCustomColor,
      'customPrimaryColor': customPrimaryColor?.value,
      'customSecondaryColor': customSecondaryColor?.value,
    };
  }

  // 保存配置
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toJson()));
  }

  // 加载配置
  static Future<ThemeStyleConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) {
      return ThemeStyleConfig();
    }
    try {
      final json = Map<String, dynamic>.from(jsonDecode(jsonString) as Map<String, dynamic>);
      return ThemeStyleConfig.fromJson(json);
    } catch (e) {
      return ThemeStyleConfig();
    }
  }

  // 获取所有可用的主题样式
  static List<String> get availableStyles => [
        // material,
        // ios,
        // switch_,
        segmented,
        // slider,
        // preview,
        // card3d,
        animated,
        // glass,
        // neon,
        // liquid,
      ];

  // 获取主题样式的显示名称
  static String getStyleName(String style) {
    switch (style) {
      case material:
        return 'Material 主题';
      case ios:
        return 'iOS 主题';
      case switch_:
        return '开关式主题';
      case segmented:
        return '分段式主题';
      case slider:
        return '滑块式主题';
      case preview:
        return '动态预览主题';
      case card3d:
        return '3D卡片主题';
      case animated:
        return '动画切换主题';
      case glass:
        return '玻璃态主题';
      case neon:
        return '霓虹主题';
      case liquid:
        return '液态主题';
      default:
        return '未知主题';
    }
  }
}
