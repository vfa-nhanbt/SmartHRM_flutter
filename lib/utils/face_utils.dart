import 'package:camera/camera.dart';

class FaceUtils {
  FaceUtils._internal();

  static FaceUtils instance = FaceUtils._internal();

  factory FaceUtils() {
    return instance;
  }

  Future<CameraDescription> getCamera() async {
    return await availableCameras().then(
      (camDes) => camDes.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.front),
    );
  }
}
