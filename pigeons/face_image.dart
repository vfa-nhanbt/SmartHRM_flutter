import 'package:pigeon/pigeon.dart';

class FaceImage {
  List<Uint8List?>? encodedImage;
  int? imageWidth;
  int? imageHeight;
  int? left;
  int? top;
  int? faceWidth;
  int? faceHeight;
  double? rotX;
  double? rotY;
}

@HostApi()
abstract class FaceImageApi {
  String processImage(FaceImage faceImage);
}
