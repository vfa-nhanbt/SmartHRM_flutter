import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final ByteData bytes =
        await rootBundle.load('assets/images/asset_face_image.jpg');
    final Uint8List assetsImageBytes = bytes.buffer.asUint8List();

    await AppValues.instance.methodChannel.invokeMethod<String>(
      'SendImage',
      <String, dynamic>{
        'capturedImage': imageBytes,
        'assetsImage': assetsImageBytes,
      },
    ).then(
      (value) {
        log(value ?? "Cannot get any value from native");
      },
    );
  }
}
