import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smarthrm_flutter/app.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Set up camera
  cameras = await availableCameras();

  runApp(const SmartHRMApp());
}
