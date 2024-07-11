import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeNotifier extends ChangeNotifier with WidgetsBindingObserver {
  String _currentTheme = 'standard';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier() {
    WidgetsBinding.instance.addObserver(this);
    _setStatusBarAndNavigationBarColors();
  }

  String get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
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
            labelLarge: TextStyle(color: Colors.orange), // Explicitly set text color
          ),
          colorScheme: const ColorScheme.light(
            surface: Colors.white,
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
            labelLarge: TextStyle(color: Colors.blueGrey), // Explicitly set text color
          ),
          colorScheme: const ColorScheme.light(
            surface: Colors.white,
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
            labelLarge: TextStyle(color: Colors.black), // Explicitly set text color
          ),
          colorScheme: const ColorScheme.light(
            surface: Colors.white,
            primary: Colors.black,
            secondary: Colors.white,
          ),
        );
      case 'vibrant':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFF00FFFF), // Cyan
          secondaryHeaderColor: const Color(0xFFFF00FF), // Fuchsia
          scaffoldBackgroundColor: const Color(0xFFFFFFfd),
          cardColor: const Color(0xFF00FF00), // Green
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF0000FF), fontWeight: FontWeight.w700), // Blue
            bodyMedium: TextStyle(color: Color(0xFF0000FF), fontWeight: FontWeight.w500), // Blue
            headlineSmall: TextStyle(color: Color(0xFFFF0000), fontWeight: FontWeight.w900), // Red
            labelLarge: TextStyle(color: Color(0xFFFF00FF)), // Fuchsia
          ),
          colorScheme: const ColorScheme.light(
            surface: Color(0xFFFFFFff),
            primary: Color(0xFF00FFFF), // Cyan
            secondary: Color(0xFFFF00FF), // Fuchsia
            tertiary: Color(0xFF00FF00), // Green
            background: Color(0xFFFFFFff),
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
            labelLarge: TextStyle(color: Colors.black), // Explicitly set text color
          ),
          colorScheme: const ColorScheme.light(
            surface: Colors.white,
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
            labelLarge: TextStyle(color: Colors.orange), // Explicitly set text color
          ),
          colorScheme: const ColorScheme.dark(
            surface: Colors.black,
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
            labelLarge: TextStyle(color: Colors.blueGrey), // Explicitly set text color
          ),
          colorScheme: ColorScheme.dark(
            surface: Colors.blueGrey[900]!,
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
            labelLarge: TextStyle(color: Colors.white), // Explicitly set text color
          ),
          colorScheme: const ColorScheme.dark(
            surface: Colors.black,
            primary: Colors.black,
            secondary: Colors.white,
          ),
        );
      case 'vibrant':
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF00FFFF), // Cyan
          secondaryHeaderColor: const Color(0xFFFF00FF), // Fuchsia
          scaffoldBackgroundColor: const Color(0xFF000000), // Black
          cardColor: const Color(0xFF00FF00), // Green
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFFFFF00), fontWeight: FontWeight.w700), // Yellow
            bodyMedium: TextStyle(color: Color(0xFFFFFF00), fontWeight: FontWeight.w500), // Yellow
            headlineSmall: TextStyle(color: Color(0xFFFF0000), fontWeight: FontWeight.w900), // Red
            labelLarge: TextStyle(color: Color(0xFF00FFFF)), // Cyan
          ),
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF000000), // Black
            primary: Color(0xFF00FFFF), // Cyan
            secondary: Color(0xFFFF00FF), // Fuchsia
            tertiary: Color(0xFF00FF00), // Green
            background: Color(0xFF000000), // Black
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
            labelLarge: TextStyle(color: Colors.white), // Explicitly set text color
          ),
          colorScheme: const ColorScheme.dark(
            surface: Colors.black,
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
    notifyListeners();
    _setStatusBarAndNavigationBarColors();
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
