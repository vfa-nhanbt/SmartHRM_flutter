import 'package:flutter/material.dart';

import 'app.dart';
import 'utils/dependency_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initDependency();

  runApp(const SmartHRMApp());
}

Future<void> _initDependency() async {
  await DependencyInitializer.init();
}
