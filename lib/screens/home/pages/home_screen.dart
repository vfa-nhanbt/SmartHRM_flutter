import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/src/camera_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_commons/src/input_image.dart';

import '../../../config/colors.dart';
import '../models/face_image.dart';
import '../services/ml_kit_service.dart';
import 'widgets/camera_view.dart';
import 'widgets/home_clock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MLKitService mlKitService = GetIt.I<MLKitService>();

  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void dispose() {
    _canProcess = false;
    mlKitService.faceDetector.close();
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
          CameraView(
            onImage: (inputImage, cameraImage, bytes) => processImage(
              inputImage,
              cameraImage,
              bytes,
            ),
          ),
          const HomeClock(),
        ],
      ),
    );
  }

  Future<void> processImage(InputImage inputImage, CameraImage cameraImage,
      List<Uint8List> bytes) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    await mlKitService.faceDetector.processImage(inputImage).then(
      (faces) async {
        if (faces.isNotEmpty) {
          await FaceImageApi()
              .processImage(
                FaceImage(
                  encodedImage: bytes,
                  imageWidth: cameraImage.width,
                  imageHeight: cameraImage.height,
                  faceHeight: faces.first.boundingBox.height.toInt(),
                  faceWidth: faces.first.boundingBox.width.toInt(),
                  left: faces.first.boundingBox.left.toInt(),
                  top: faces.first.boundingBox.top.toInt(),
                  rotX: faces.first.headEulerAngleX,
                  rotY: faces.first.headEulerAngleY,
                ),
              )
              .then(
                (value) => log(value),
              )
              .catchError(
                (err) => log(
                  err is PlatformException
                      ? "${err.code} - ${err.message}"
                      : "Unexpected Error!",
                ),
              );
        }
      },
    ).catchError(
      (err) {
        log(err);
      },
    );

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
