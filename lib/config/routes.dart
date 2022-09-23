import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/home/pages/home_screen.dart';

class AppRoutes {
  AppRoutes._internal();

  static final AppRoutes _singleton = AppRoutes._internal();

  factory AppRoutes() {
    return _singleton;
  }

  // Route name
  static const String home = "/home";

  // initial Route
  static String get init => home;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return CupertinoPageRoute(
          builder: (context) => HomeScreen(),
        );
      default:
        return _errorRoute();
    }
  }

  Route _errorRoute() {
    return CupertinoPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('Error'),
        ),
      ),
      settings: const RouteSettings(
        name: '/error',
      ),
    );
  }
}
