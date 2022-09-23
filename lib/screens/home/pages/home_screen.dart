import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../../config/values.dart';
import '../services/camera_service.dart';
import '../services/ml_kit_service.dart';
import 'widgets/home_clock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraService cameraService = GetIt.I<CameraService>();
  MLKitService mlKitService = GetIt.I<MLKitService>();
  List<Face> faces = [];

  bool _initializing = false;
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() async {
    setState(() => _initializing = true);
    await cameraService.initialize();
    setState(() => _initializing = false);

    // cameraService.cameraController?.startImageStream(processCameraImage);
  }

  @override
  void dispose() {
    cameraService.dispose();
    _canProcess = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // await cameraService.cameraController?.stopImageStream();
            final image = await cameraService.takePicture();
            // cameraService.cameraController
            //     ?.startImageStream(processCameraImage);

            processCapturedImage(image!);
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future processCameraImage(CameraImage image) async {
    if (cameraService.cameraController != null) {
      final InputImage inputImage = mlKitService.createInputImage(
        image,
        cameraService.cameraRotation!,
      );

      if (!_canProcess) return;
      if (_isBusy) return;
      _isBusy = true;
      setState(() {});

      try {
        faces = await mlKitService.faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          try {
            final image = await cameraService.takePicture();

            processCapturedImage(image!);
          } catch (e) {
            print(e);
          }
        }
      } catch (e) {
        print(e);
      }

      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> processCapturedImage(XFile image) async {
    Uint8List imageBytes = await image.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    AppValues.instance.methodChannel.invokeMethod<String>(
      'SendImageBase64String',
      <String, dynamic>{
        'image': base64Image,
      },
    ).then(
      (value) {
        log(value ?? "Cannot get any value from native");
        // log(faces.length.toString());
      },
    );
  }
}
