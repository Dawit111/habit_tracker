import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/dark_mode.dart';
import 'package:habit_tracker/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // initialize theme data
  ThemeData _themeData = lightMode;

  // getter method to get current theme mode
  ThemeData get themeData => _themeData;

  // boolean that returns true or false depending on the current theme is darkmode or not
  bool get isDarkMode => _themeData == darkMode;

  // setter method to set current theme mode
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // toggle method

  void toggleTheme() {
    _themeData == darkMode ? themeData = lightMode : themeData = darkMode;
  }
}
