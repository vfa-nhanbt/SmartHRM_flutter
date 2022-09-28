import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => this._cameraController;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => this._cameraRotation;

  Future<void> initialize() async {
    if (_cameraController != null) return;
    CameraDescription description = await _getCameraDescription();
    await _setupCameraController(description: description);
    this._cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere((CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front);
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    this._cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController?.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation0deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<XFile?> takePicture() async {
    assert(_cameraController != null, 'Camera controller not initialized');
    return await _cameraController?.takePicture();
  }

  startStream(Function(CameraImage) onAvailable) {
    this._cameraController?.startImageStream(onAvailable);
  }

  stopStream() async {
    await this.cameraController?.stopImageStream();
  }

  dispose() async {
    await this._cameraController?.dispose();
    this._cameraController = null;
  }
}

extension createEncodeImage on CameraImage {
  Uint8List _createUint8List(Uint8List bytes) {
    WriteBuffer allBytes = WriteBuffer();
    allBytes.putUint8List(bytes);
    return allBytes.done().buffer.asUint8List();
  }

  List<Uint8List> toListUint8List() {
    List<Uint8List> listUint8List = [];
    listUint8List.add(_createUint8List(this.planes[0].bytes));
    listUint8List.add(_createUint8List(this.planes[1].bytes));
    listUint8List.add(_createUint8List(this.planes[2].bytes));
    return listUint8List;
  }
}
