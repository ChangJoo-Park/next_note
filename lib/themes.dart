import 'package:flutter/material.dart';
import 'package:next_page/custom_theme.dart';

enum MyThemeKeys { LIGHT, BLUE, DARK, DARKER }

class MyThemes {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.white,
    accentColor: Colors.black,
    brightness: Brightness.light,
  );

  static final ThemeData blueTheme = ThemeData(
    primaryColor: Colors.blue,
    accentColor: Colors.blueAccent,
    brightness: Brightness.light,
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.grey,
    brightness: Brightness.dark,
  );

  static final ThemeData darkerTheme = ThemeData(
    primaryColor: Colors.black,
    brightness: Brightness.dark,
  );

  static ThemeData getThemeFromKey(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.LIGHT:
        return lightTheme;
      case MyThemeKeys.BLUE:
        return blueTheme;
      case MyThemeKeys.DARK:
        return darkTheme;
      case MyThemeKeys.DARKER:
        return darkerTheme;
      default:
        return lightTheme;
    }
  }

  static MyThemeKeys getThemeFromStringKey(String themeKey) {
    switch (themeKey) {
      case 'light':
        return MyThemeKeys.LIGHT;
      case 'blue':
        return MyThemeKeys.BLUE;
      case 'dark':
        return MyThemeKeys.DARK;
      case 'darker':
        return MyThemeKeys.DARKER;
      default:
        return MyThemeKeys.LIGHT;
    }
  }

  static void changeTheme(BuildContext buildContext, MyThemeKeys key) {
    CustomTheme.instanceOf(buildContext).changeTheme(key);
  }

  static getThemeString(MyThemeKeys themeKey) {
    switch (themeKey) {
      case MyThemeKeys.LIGHT:
        return 'light';
      case MyThemeKeys.BLUE:
        return 'blue';
      case MyThemeKeys.DARK:
        return 'dark';
      case MyThemeKeys.DARKER:
        return 'darker';
      default:
        return 'unknown';
    }
  }
}
