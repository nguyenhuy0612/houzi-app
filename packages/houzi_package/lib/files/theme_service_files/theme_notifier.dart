import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/theme_service_files/theme_storage_manager.dart';

class ThemeNotifier with ChangeNotifier {

    ThemeMode? _themeMode;
    ThemeMode? getThemeMode() => _themeMode;

  static ThemeNotifier? _themeNotifier;

  factory ThemeNotifier() {
    _themeNotifier ??= ThemeNotifier._internal();
    return _themeNotifier!;
  }
  bool isDarkMode(){
    bool isDarkMode = false;

    if (_themeMode == ThemeMode.system) {
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
    } else if (_themeMode == ThemeMode.dark) {
      isDarkMode = true;
    } else if (_themeMode == ThemeMode.light) {
      isDarkMode = false;
    }

    return isDarkMode;
  }
  ThemeNotifier._internal(){
    String themeMode = ThemeStorageManager.readData(THEME_MODE_INFO) ?? LIGHT_THEME_MODE;
    if(themeMode == null || themeMode.isEmpty){
      _themeMode = ThemeMode.light;
      // _themeMode = ThemeMode.system;
    }else if (themeMode == LIGHT_THEME_MODE) {
      _themeMode = ThemeMode.light;
    } else if (themeMode == DARK_THEME_MODE){
      _themeMode = ThemeMode.dark;
    } else if (themeMode == SYSTEM_THEME_MODE){
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setDarkMode(){
    _themeMode = ThemeMode.dark;
    ThemeStorageManager.saveData(THEME_MODE_INFO, DARK_THEME_MODE);
    notifyListeners();
  }

  void setLightMode(){
    _themeMode = ThemeMode.light;
    ThemeStorageManager.saveData(THEME_MODE_INFO, LIGHT_THEME_MODE);
    notifyListeners();
  }

  void setSystemThemeMode(){
    _themeMode = ThemeMode.system;
    ThemeStorageManager.saveData(THEME_MODE_INFO, SYSTEM_THEME_MODE);
    notifyListeners();
  }
}