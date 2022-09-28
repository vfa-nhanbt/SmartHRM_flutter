import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../services/camera_service.dart';
import '../../services/ml_kit_service.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.onImage,
  }) : super(key: key);

  final Function(
    InputImage inputImage,
    CameraImage cameraImage,
    List<Uint8List> bytes,
  ) onImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraService cameraService = GetIt.I<CameraService>();
  MLKitService mlKitService = GetIt.I<MLKitService>();

  bool _initializing = false;

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  @override
  void dispose() {
    stopCamera();
    cameraService.dispose();

    super.dispose();
  }

  initCamera() async {
    setState(() => _initializing = true);
    await cameraService.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }

        cameraService.startStream(processCameraImage);
        setState(() {});
      },
    );
    setState(() => _initializing = false);
  }

  Future stopCamera() async {
    await cameraService.stopStream();
  }

  Future processCameraImage(CameraImage image) async {
    final List<Uint8List> bytes = image.toListUint8List();

    final InputImage inputImage = mlKitService.createInputImageFromCameraImage(
      image,
      cameraService.cameraRotation!,
    );

    widget.onImage(
      inputImage,
      image,
      bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _initializing
          ? CircularProgressIndicator()
          : Container(
              child: CameraPreview(cameraService.cameraController!),
            ),
    );
  }
}
