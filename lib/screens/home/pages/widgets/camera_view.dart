// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// import '../../services/camera_service.dart';
// import '../../services/ml_kit_service.dart';

// class CameraView extends StatefulWidget {
//   const CameraView({
//     Key? key,
//     required this.onProcessImage,
//   }) : super(key: key);

//   final Function(InputImage inputIMage) onProcessImage;

//   @override
//   State<CameraView> createState() => _CameraViewState();
// }

// class _CameraViewState extends State<CameraView> {
//   CameraService cameraService = GetIt.I<CameraService>();
//   MLKitService mlKitService = GetIt.I<MLKitService>();

//   bool _initializing = false;
//   bool _canProcess = true;
//   bool _isBusy = false;

//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//   }

//   initCamera() async {
//     setState(() => _initializing = true);
//     await cameraService.initialize().then(
//       (_) {
//         if (!mounted) {
//           return;
//         }

//         cameraService.cameraController?.startImageStream(processCameraImage);
//         setState(() {});
//       },
//     );
//     setState(() => _initializing = false);
//   }

//   @override
//   void dispose() {
//     cameraService.dispose();
//     _canProcess = false;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         alignment: Alignment.bottomCenter,
//         children: [
//           _initializing
//               ? CircularProgressIndicator()
//               : Container(
//                   child: CameraPreview(cameraService.cameraController!),
//                 ),
//           const HomeClock(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           try {
//             final image = await cameraService.takePicture();

//             if (!mounted) return;

//             processCapturedImage(image!);
//           } catch (e) {
//             print(e);
//           }
//         },
//         child: const Icon(Icons.camera_alt),
//       ),
//     );
//   }

//   Future processCameraImage(CameraImage image) async {
//     final InputImage inputImage = mlKitService.createInputImage(
//       image,
//       cameraService.cameraRotation!,
//     );

//     if (!_canProcess) return;
//     if (_isBusy) return;
//     _isBusy = true;
//     setState(() {});

//     mlKitService.faces =
//         await mlKitService.faceDetector.processImage(inputImage);

//     _isBusy = false;
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   Future<void> processCapturedImage(XFile image) async {
//     if (!_canProcess) return;
//     if (_isBusy) return;
//     _isBusy = true;
//     setState(() {});

//     Uint8List imageBytes = await image.readAsBytes();
//     String base64Image = base64Encode(imageBytes);
//     AppValues.instance.methodChannel.invokeMethod<String>(
//       'SendImageBase64String',
//       <String, dynamic>{
//         'image': base64Image,
//       },
//     ).then(
//       (value) => log(value ?? "Cannot get any value from native"),
//     );

//     _isBusy = false;
//     if (mounted) {
//       setState(() {});
//     }
//   }
// }
