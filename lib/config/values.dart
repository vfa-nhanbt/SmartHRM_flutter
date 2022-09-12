import 'package:flutter/services.dart';

class AppValues {
  AppValues._internal();

  static AppValues instance = AppValues._internal();

  factory AppValues() {
    return instance;
  }

  final methodChannel =
      MethodChannel("com.example.smarthrm_flutter/method-channel/");
}
