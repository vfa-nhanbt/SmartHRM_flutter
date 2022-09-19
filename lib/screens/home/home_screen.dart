import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:smarthrm_flutter/config/values.dart';
import 'package:smarthrm_flutter/screens/home/widgets/w_camera_view.dart';

import '../../config/colors.dart';
import 'widgets/w_home_clock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _canProcess = true;
  bool _isBusy = false;

  final detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
    ),
  );

  @override
  void dispose() {
    _canProcess = false;
    detector.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Robot HRM"),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        foregroundColor: AppColors.blackColor,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: CameraView(
              onProcessImage: (inputImage) => processImage(inputImage),
              onStreamCameraImage: (cameraImage) =>
                  processCameraImage(cameraImage),
            ),
          ),
          const HomeClock(),
        ],
      ),
    );
  }

  Future<void> processCameraImage(CameraImage image) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final String imageString = base64Encode(bytes);

    AppValues.instance.methodChannel.invokeMethod<dynamic>(
      'processCameraImage',
      <String, dynamic>{
        'image': imageString,
      },
    );

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    final faces = await detector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      if (faces.isNotEmpty) {
        log("face detected: " + faces.first.toString());
        AppValues.instance.methodChannel.invokeMethod(
          "SendFaces",
          {
            "face": faces.first,
          },
        );
      } else {
        log("No faces founded!");
      }
    } else {
      log("ERROR!");
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
