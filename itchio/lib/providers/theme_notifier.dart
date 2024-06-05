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
          backgroundColor: Colors.lightGreen[100],
          scaffoldBackgroundColor: Colors.lightGreen[100],
          cardColor: Colors.orange[200],
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.orange[900]),
            bodyText2: TextStyle(color: Colors.orange[800]),
            headline6: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
          ),
        );
      case 'abyss':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blueGrey,
          secondaryHeaderColor: Colors.deepPurple,
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.blueGrey[100],
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.blueGrey[900]),
            bodyText2: TextStyle(color: Colors.blueGrey[800]),
            headline6: TextStyle(color: Colors.blueGrey[700], fontWeight: FontWeight.bold),
          ),
        );
      case 'hardContrast':
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
          secondaryHeaderColor: Colors.white,
          backgroundColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.black,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white),
            headline6: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return ThemeData.light().copyWith(
          cardColor: Colors.white,
          primaryColor: Colors.black,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.black),
            bodyText2: TextStyle(color: Colors.black54),
            headline6: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          backgroundColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.orange[800],
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.orange[100]),
            bodyText2: TextStyle(color: Colors.orange[200]),
            headline6: TextStyle(color: Colors.orange[50], fontWeight: FontWeight.bold),
          ),
        );
      case 'abyss':
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blueGrey,
          secondaryHeaderColor: Colors.deepPurple,
          backgroundColor: Colors.blueGrey[500],
          scaffoldBackgroundColor: Colors.blueGrey[900],
          cardColor: Colors.blueGrey[800],
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.blueGrey[100]),
            bodyText2: TextStyle(color: Colors.blueGrey[200]),
            headline6: TextStyle(color: Colors.blueGrey[50], fontWeight: FontWeight.bold),
          ),
        );
      case 'hardContrast':
        return ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          secondaryHeaderColor: Colors.white,
          backgroundColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.black,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white),
            headline6: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return ThemeData.dark().copyWith(
          cardColor: Colors.grey[900],
          primaryColor: Colors.white,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white70),
            headline6: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
