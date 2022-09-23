import 'package:smarthrm_flutter/screens/home/services/injection_container.dart';

class DependencyInitializer {
  DependencyInitializer._internal();

  static Future<void> init() async {
    await HomeInjectionContainer.instance.init();
  }
}
