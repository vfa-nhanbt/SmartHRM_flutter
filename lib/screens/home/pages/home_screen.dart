import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:smarthrm_flutter/screens/home/services/ml_kit_services.dart';

import '../../../config/values.dart';
import '../services/camera_service.dart';
import 'widgets/home_clock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraService cameraService = GetIt.I<CameraService>();
  MLKitService mlKitService = GetIt.I<MLKitService>();

  bool _initializing = false;
  // bool _canProcess = true;
  // bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() async {
    setState(() => _initializing = true);
    await cameraService.initialize();
    setState(() => _initializing = false);
  }

  @override
  void dispose() {
    cameraService.dispose();
    // _canProcess = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            _initializing
                ? CircularProgressIndicator()
                : Container(
                    child: CameraPreview(cameraService.cameraController!),
                  ),
            const HomeClock(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final image = await cameraService.takePicture();

            processCapturedImage(image!);
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> processCapturedImage(XFile image) async {
    final Uint8List imageBytes = await image.readAsBytes();

    final inputImage = mlKitService.createInputImageFromAssetImage(image.path);
    final faces = await mlKitService.faceDetector.processImage(inputImage);
    log(faces.length.toString());

    if (faces.isNotEmpty) {
      await AppValues.instance.methodChannel.invokeMethod<String>(
        'SendImage',
        <String, dynamic>{
          'capturedImage': imageBytes,
          'left': faces.first.boundingBox.left.toInt(),
          'top': faces.first.boundingBox.top.toInt(),
          'width': faces.first.boundingBox.width.toInt(),
          'height': faces.first.boundingBox.height.toInt(),
          'rotX': faces.first.headEulerAngleX,
          'rotY': faces.first.headEulerAngleY,
        },
      ).then(
        (value) {
          log(value ?? "Cannot get any value from native");
        },
      );
    }
  }
}
