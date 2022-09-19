// import 'dart:developer';
// import 'dart:io';

// import 'package:tflite_flutter/tflite_flutter.dart';

// class Classifier {
//   Classifier._internal();

//   static Classifier instance = Classifier._internal();

//   factory Classifier() {
//     return instance;
//   }

//   late Interpreter interpreter;

//   initializeInterpreter() async {
//     Delegate? delegate;
//     try {
//       if (Platform.isAndroid) {
//         delegate = GpuDelegateV2(
//           options: GpuDelegateOptionsV2(
//             isPrecisionLossAllowed: false,
//             inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
//             inferencePriority1: TfLiteGpuInferencePriority.minLatency,
//             inferencePriority2: TfLiteGpuInferencePriority.auto,
//             inferencePriority3: TfLiteGpuInferencePriority.auto,
//           ),
//         );
//       } else if (Platform.isIOS) {
//         delegate = GpuDelegate(
//           options: GpuDelegateOptions(
//               allowPrecisionLoss: true,
//               waitType: TFLGpuDelegateWaitType.active),
//         );
//       }
//       var interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

//       interpreter = await Interpreter.fromAsset(
//         'mobilefacenet.tflite',
//         options: interpreterOptions,
//       );
//     } catch (e) {
//       log('Failed to load model.');
//       log(e.toString());
//     }
//   }
// }
