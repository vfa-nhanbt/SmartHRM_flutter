import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smarthrm_flutter/config/values.dart';

import '../../main.dart';

class RegisterFace extends StatefulWidget {
  const RegisterFace({super.key});

  @override
  RegisterFaceState createState() => RegisterFaceState();
}

class RegisterFaceState extends State<RegisterFace> {
  late CameraController _controller;
  bool _initializing = false;
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
    );

    _start();
  }

  Future _start() async {
    setState(() => _initializing = true);
    await _controller.initialize();
    setState(() => _initializing = false);
    _frameFaces();
  }

  _frameFaces() async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    _controller.startImageStream((CameraImage image) async {
      sendImageToNative(image);
    });

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  sendImageToNative(CameraImage image) async {
    List<Uint8List> bytes = [];
    WriteBuffer allBytes = WriteBuffer();
    allBytes.putUint8List(image.planes[0].bytes);
    bytes.add(allBytes.done().buffer.asUint8List());
    allBytes = WriteBuffer();
    allBytes.putUint8List(image.planes[1].bytes);
    bytes.add(allBytes.done().buffer.asUint8List());
    allBytes = WriteBuffer();
    allBytes.putUint8List(image.planes[2].bytes);
    bytes.add(allBytes.done().buffer.asUint8List());

    await AppValues.instance.methodChannel.invokeMethod<String>(
      "SendImageToNative",
      {
        "encodeImage": bytes,
        "width": image.width,
        "height": image.height,
      },
    ).then(
      (value) => log(value ?? "Cannot get any value from native"),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: _initializing
                ? CircularProgressIndicator()
                : CameraPreview(_controller),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final image = await _controller.takePicture();

            if (!mounted) return;
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
