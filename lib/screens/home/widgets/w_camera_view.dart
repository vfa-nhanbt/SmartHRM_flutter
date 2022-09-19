import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:smarthrm_flutter/screens/register_face/helper/face_utils.dart';

import '../../../main.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.onProcessImage,
    this.onStreamCameraImage,
  }) : super(key: key);

  // final Function(String base64Image)? onProcessImage;
  final Function(InputImage inputIMage) onProcessImage;
  final Function(CameraImage cameraImage)? onStreamCameraImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  int _cameraIndex = 1;
  late FaceDetector detector;

  @override
  void initState() {
    super.initState();

    detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableContours: true,
      ),
    );

    startLiveCamera();
  }

  @override
  void dispose() {
    stopLiveCamera();

    detector.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Center(
            child: CameraPreview(_controller!),
          ),
          TextButton(
            onPressed: () async {
              final image = await _controller?.takePicture();

              if (!mounted) return;

              Uint8List imageBytes = await image!.readAsBytes();
              String base64Image = base64Encode(imageBytes);

              log(base64Image);
              // widget.onProcessImage(base64Image);
            },
            child: Text("Capture"),
          ),
        ],
      ),
    );
    // );
  }

  Future startLiveCamera() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _controller?.startImageStream(processCameraImage);
      setState(() {});
    });
  }

  Future stopLiveCamera() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future processCameraImage(CameraImage image) async {
    final InputImage inputImage = FaceUtils.instance.createInputImage(
      image,
      _controller!.description.sensorOrientation,
    );

    widget.onProcessImage(inputImage);
  }
}
