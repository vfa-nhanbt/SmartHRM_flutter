import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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

    startStream();
  }

  @override
  void dispose() {
    cameraService.dispose();
    _canProcess = false;
    super.dispose();
  }

  startStream() async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    cameraService.startStream(
      (CameraImage image) async => sendImageToNative(image),
    );

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
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
    );
  }

  sendImageToNative(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    await AppValues.instance.methodChannel.invokeMethod<String>(
      "SendImage",
      {
        "encodeImage": bytes,
      },
    ).then(
      (value) => log(value ?? "Cannot get any value from native"),
    );
  }
}
