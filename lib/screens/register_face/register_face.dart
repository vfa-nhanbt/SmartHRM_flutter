import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smarthrm_flutter/main.dart';
import 'package:smarthrm_flutter/screens/home/widgets/w_home_clock.dart';

import '../../config/values.dart';

// A screen that allows users to take a picture using a given camera.
class RegisterFace extends StatefulWidget {
  const RegisterFace({super.key});

  @override
  RegisterFaceState createState() => RegisterFaceState();
}

class RegisterFaceState extends State<RegisterFace> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _canProcess = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras[1],
      // Define the resolution to use.
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return Center(
                  child: CameraPreview(_controller),
                );
              } else {
                // Otherwise, display a loading indicator.
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          HomeClock(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, convert to string and send it to native side.
            processCapturedImage(image);
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> processCapturedImage(XFile image) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    Uint8List imageBytes = await image.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    AppValues.instance.methodChannel.invokeMethod<dynamic>(
      'processCameraImage',
      <String, dynamic>{
        'image': base64Image,
      },
    );

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
