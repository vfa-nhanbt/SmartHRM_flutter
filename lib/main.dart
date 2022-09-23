import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'app.dart';
import 'utils/dependency_init.dart';

List<CameraDescription> cameras = [];
List<Face> faces = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  await _initDependency();

  runApp(const SmartHRMApp());
}

Future<void> _initDependency() async {
  await DependencyInitializer.init();
}
