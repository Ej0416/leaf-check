import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PredictCameraPreview extends StatelessWidget {
  const PredictCameraPreview({
    super.key,
    required this.controller,
  });

  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 300,
      // padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      child: controller == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : !controller!.value.isInitialized
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CameraPreview(controller!),
    );
  }
}
