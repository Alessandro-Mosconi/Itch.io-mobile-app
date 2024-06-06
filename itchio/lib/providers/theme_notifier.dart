import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeNotifier extends ChangeNotifier with WidgetsBindingObserver {
  String _currentTheme = 'device';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier() {
    WidgetsBinding.instance.addObserver(this);
    _setStatusBarAndNavigationBarColors();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    notifyListeners();
    _setStatusBarAndNavigationBarColors();
  }

  String get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;

  ThemeData getLightThemeData(String theme) {
    switch (theme) {
      case 'fluxoki':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.orange,
          secondaryHeaderColor: Colors.blue,
          scaffoldBackgroundColor: Colors.lightGreen[100],
          cardColor: Colors.orange[200],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700),
            bodyMedium: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
            headlineSmall: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900),
          ),
          colorScheme: ColorScheme.light(
            background: Colors.lightGreen[100]!,
            primary: Colors.orange,
            secondary: Colors.blue,
          ),
        );
      case 'abyss':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blueGrey,
          secondaryHeaderColor: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.blueGrey[100],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w700),
            bodyMedium: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
            headlineSmall: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w900),
          ),
          colorScheme: ColorScheme.light(
            background: Colors.white,
            primary: Colors.blueGrey,
            secondary: Colors.deepPurple,
          ),
        );
      case 'hardContrast':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          secondaryHeaderColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.black,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
            bodyMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
          colorScheme: ColorScheme.light(
            background: Colors.white,
            primary: Colors.black,
            secondary: Colors.white,
          ),
        );
      default:
        return ThemeData.light().copyWith(
          cardColor: Colors.white,
          primaryColor: Colors.black,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black54),
            headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          colorScheme: ColorScheme.light(
            background: Colors.white,
            primary: Colors.black,
            secondary: Colors.black54,
          ),
        );
    }
  }

  ThemeData getDarkThemeData(String theme) {
    switch (theme) {
      case 'fluxoki':
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.orange,
          secondaryHeaderColor: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.orange[800],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700),
            bodyMedium: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
            headlineSmall: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900),
          ),
          colorScheme: ColorScheme.dark(
            background: Colors.black,
            primary: Colors.orange,
            secondary: Colors.blue,
          ),
        );
      case 'abyss':
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blueGrey,
          secondaryHeaderColor: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.blueGrey[900],
          cardColor: Colors.blueGrey[800],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w700),
            bodyMedium: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
            headlineSmall: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w900),
          ),
          colorScheme: ColorScheme.dark(
            background: Colors.blueGrey[900]!,
            primary: Colors.blueGrey,
            secondary: Colors.deepPurple,
          ),
        );
      case 'hardContrast':
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          secondaryHeaderColor: Colors.white,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.black,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          colorScheme: ColorScheme.dark(
            background: Colors.black,
            primary: Colors.black,
            secondary: Colors.white,
          ),
        );
      default:
        return ThemeData.dark().copyWith(
          cardColor: Colors.grey[900],
          primaryColor: Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
            headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          colorScheme: ColorScheme.dark(
            background: Colors.black,
            primary: Colors.white,
            secondary: Colors.white70,
          ),
        );
    }
  }

  ThemeData getThemeData() {
    if (_themeMode == ThemeMode.light) {
      return getLightThemeData(_currentTheme);
    } else if (_themeMode == ThemeMode.dark) {
      return getDarkThemeData(_currentTheme);
    } else {
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark
          ? getDarkThemeData(_currentTheme)
          : getLightThemeData(_currentTheme);
    }
  }

  void setTheme(String theme) {
    _currentTheme = theme;
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _setStatusBarAndNavigationBarColors();
  }

  void _setStatusBarAndNavigationBarColors() {
    if (_themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && WidgetsBinding.instance.window.platformBrightness == Brightness.dark)) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    }
  }
}
