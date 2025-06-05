import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _usePureBlack = false;
  late BuildContext _context;

  bool get isDarkMode => _isDarkMode;
  bool get usePureBlack => _usePureBlack;

  void setContext(BuildContext context) {
    _context = context;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    if (_isDarkMode) {
      AdaptiveTheme.of(_context).setDark();
    } else {
      AdaptiveTheme.of(_context).setLight();
    }
    notifyListeners();
  }

  void togglePureBlack() {
    _usePureBlack = !_usePureBlack;
    if (_isDarkMode) {
      AdaptiveTheme.of(_context).setDark();
    }
    notifyListeners();
  }
}
