// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceUtils {
  FaceUtils._internal();

  static FaceUtils instance = FaceUtils._internal();

  factory FaceUtils() {
    return instance;
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<PlatformArguments> detectFacesFromImage({
    required CameraImage image,
    required int rotation,
    required FaceDetector detector,
  }) async {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation: rotationIntToImageRotation(rotation),
      inputImageFormat: InputImageFormat.bgra8888,
      size: Size(
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      planeData: image.planes.map(
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
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage _firebaseVisionImage = InputImage.fromBytes(
      bytes: bytes,
      inputImageData: _firebaseImageMetadata,
    );

    final String base64 = base64Encode(bytes);
    final List<Face> faces = await detector.processImage(_firebaseVisionImage);

    return PlatformArguments(
      faces: faces,
      bitmapString: base64,
    );
  }

  InputImage createInputImage(CameraImage image, int rotation) {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation: rotationIntToImageRotation(rotation),
      inputImageFormat: InputImageFormat.bgra8888,
      size: Size(
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      planeData: image.planes.map(
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
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: _firebaseImageMetadata,
    );
  }
}

class PlatformArguments extends Equatable {
  final List<Face> faces;
  final String bitmapString;

  PlatformArguments({
    required this.faces,
    required this.bitmapString,
  });

  @override
  List<Object?> get props => [
        faces,
        bitmapString,
      ];
}
