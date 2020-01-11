import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:next_page/custom_theme.dart';
import 'package:next_page/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/locator.dart';
import 'core/providers.dart';
import 'core/services/navigator_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setTargetPlatformForDesktop();
  await LocatorInjector.setupLocator();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String theme = prefs.getString('theme');
  MyThemeKeys themeKey = MyThemes.getThemeFromStringKey(theme);

  runApp(
    CustomTheme(
      initialThemeKey: themeKey,
      child: MainApplication(),
    ),
  );
}

void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

class MainApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProviderInjector.providers,
      child: MaterialApp(
        theme: CustomTheme.of(context),
        debugShowCheckedModeBanner: false,
        navigatorKey: locator<NavigatorService>().navigatorKey,
        home: HomeView(),
      ),
    );
  }
}
