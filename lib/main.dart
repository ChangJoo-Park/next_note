import 'core/locator.dart';
import 'core/providers.dart';
import 'core/services/navigator_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home/home_view.dart';
import 'package:dotenv/dotenv.dart' show load, env;

void main() async {
  load('development.env');
  await LocatorInjector.setupLocator();
  runApp(MainApplication());
}

class MainApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primaryColor: Colors.white,
      accentColor: Colors.black,
    );

    final ThemeData darkTheme = ThemeData.dark();

    return MultiProvider(
      providers: ProviderInjector.providers,
      child: MaterialApp(
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: locator<NavigatorService>().navigatorKey,
        home: HomeView(),
      ),
    );
  }
}
