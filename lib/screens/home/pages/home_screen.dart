import 'dart:developer';
import 'dart:typed_data';

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
    List<Uint8List> bytes = [];
    bytes.add(createUint8List(image.planes[0].bytes));
    bytes.add(createUint8List(image.planes[1].bytes));
    bytes.add(createUint8List(image.planes[2].bytes));

    await AppValues.instance.methodChannel.invokeMethod<String>(
      "SendImage",
      {
        "encodeImage": bytes,
        "width": image.width,
        "height": image.height,
      },
    ).then(
      (value) => log(value ?? "Cannot get any value from native"),
    );
  }

  Uint8List createUint8List(Uint8List bytes) {
    WriteBuffer allBytes = WriteBuffer();
    allBytes.putUint8List(bytes);
    return allBytes.done().buffer.asUint8List();
  }
}
