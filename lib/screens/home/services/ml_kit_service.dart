import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MLKitService {
  FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
    ),
  );

  FaceDetector get faceDetector => _faceDetector;

  InputImage createInputImageFromCameraImage(
          CameraImage image, InputImageRotation rotation) =>
      image.toInputImage(rotation);

  InputImage createInputImageFromAssetImage(String filePath) =>
      InputImage.fromFilePath(filePath);
}

extension createInputImage on CameraImage {
  InputImage toInputImage(InputImageRotation rotation) {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation: rotation,
      inputImageFormat: InputImageFormat.bgra8888,
      size: Size(
        this.width.toDouble(),
        this.height.toDouble(),
      ),
      planeData: this.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in this.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: _firebaseImageMetadata,
    );
  }
}
