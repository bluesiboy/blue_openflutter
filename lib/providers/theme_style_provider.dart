import 'package:flutter/material.dart';
import '../models/theme_style_config.dart';

class ThemeStyleProvider extends ChangeNotifier {
  final ThemeStyleConfig _config;

  ThemeStyleProvider(this._config);

  ThemeStyleConfig get config => _config;

  Future<void> updateStyle(String style) async {
    _config.currentStyle = style;
    await _config.save();
    notifyListeners();
  }

  Future<void> updatePureBlack(bool value) async {
    _config.usePureBlack = value;
    await _config.save();
    notifyListeners(); // 确保调用
  }

  Future<void> updateAnimation(bool value) async {
    _config.enableAnimation = value;
    await _config.save();
    notifyListeners();
  }

  Future<void> updateCustomColor(bool value) async {
    _config.enableCustomColor = value;
    await _config.save();
    notifyListeners();
  }

  Future<void> updateCustomColors({
    Color? primaryColor,
    Color? secondaryColor,
  }) async {
    bool changed = false;

    if (primaryColor != null && _config.customPrimaryColor != primaryColor) {
      _config.customPrimaryColor = primaryColor;
      changed = true;
    }

    if (secondaryColor != null && _config.customSecondaryColor != secondaryColor) {
      _config.customSecondaryColor = secondaryColor;
      changed = true;
    }

    if (changed) {
      await _config.save();
      notifyListeners(); // 确保调用
    }
  }
}
