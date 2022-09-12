import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../config/colors.dart';
import 'widgets/w_camera_view.dart';
import 'widgets/w_face_detector_painter.dart';
import 'widgets/w_home_clock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;

  /// GoogleML kit face detector instance
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
    ),
  );

  @override
  void dispose() {
    _canProcess = false;
    faceDetector.close();
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
              customPaint: _customPaint,
              onImage: (inputImage) {
                processImage(inputImage);
              },
            ),
          ),
          const HomeClock(),
        ],
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    final faces = await faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
