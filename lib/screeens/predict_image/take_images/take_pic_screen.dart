import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leafcheck_project_v2/screeens/dash_board/dashboard_screen.dart';
import 'package:leafcheck_project_v2/screeens/predict_image/take_images/preview_images.dart';
import 'package:tflite/tflite.dart';

import 'camera_preview.dart';
import 'confimr_identify.dart';

class TakePicScreen extends StatefulWidget {
  const TakePicScreen({super.key});

  @override
  State<TakePicScreen> createState() => _TakePicScreenState();
}

class _TakePicScreenState extends State<TakePicScreen> {
  late List<XFile> imageList = [];
  late List<File> resizeImageList = [];
  late List<CameraDescription> cameras;
  CameraController? controller;
  File? image2;
  XFile? image;
  final _picker = ImagePicker();
  late bool _isLoading = false;
  int notALeafImg = 0;

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      debugPrint("No Camera found");
    }
  }

  late List _result;
  String confidence = '';
  String name = '';
  File? _image;

  loadModel() async {
    var result = await Tflite.loadModel(
      model: "assets/leaf_not/tf_lite_model.tflite",
      labels: "assets/leaf_not/labels.txt",
    );
  }

  predict(File file) async {
    debugPrint(
        '-------------------------preiction start------------------------');
    try {
      var res = await Tflite.runModelOnImage(
        path: file.path,
        // defaults to 0.1
      );

      setState(() {
        _result = res!;
        name = _result[0]["label"];
        confidence = _result != null
            ? "${(_result[0]["confidence"] * 100).toString().substring(0, 2)}%"
            : "";
      });
    } catch (e) {
      debugPrint("there is an error: $e");
    }

    debugPrint(_result.toString());
  }

  @override
  void initState() {
    loadModel();
    loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    resizeImageList;
    imageList;
    super.dispose();
  }

  Future getImages() async {
    List<XFile>? xfilePick = await _picker.pickMultiImage(
        maxHeight: 650, maxWidth: 650, imageQuality: 90);
    try {
      if (xfilePick.isNotEmpty) {
        setState(() {
          _isLoading = true;
          imageList.addAll(xfilePick);
        });

        debugPrint("there shoudl be image");
        debugPrint("${imageList.length}");
        xfilePick.clear();
        await Future.delayed(const Duration(milliseconds: 1200));
        setState(() {
          _isLoading = false;
        });
      } else {
        debugPrint("Nothing is selected");
      }

      setState(() {});
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future takeImage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (controller != null) {
        if (controller!.value.isInitialized) {
          await controller!.setFlashMode(FlashMode.off);
          await controller!.setFocusMode(FocusMode.locked);
          image = await controller!.takePicture();
          debugPrint("--------------image taken------------------");

          setState(() {
            _image = File(image!.path);
            predict(_image!);
            imageList.add(image!);
          });
          await Future.delayed(const Duration(milliseconds: 650));
          setState(() {
            _isLoading = false;
          });
        }
      }
      debugPrint("${imageList.length}");
      debugPrint("The path ${image!.path}");
    } catch (e) {
      debugPrint("$e"); //show error
    }
  }

  test() {
    debugPrint(imageList[0].path);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(179, 35, 151, 60),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const DashbardScreen();
                }));
              },
            ),
            centerTitle: true,
            title: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Take Leaf Image",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Stack(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      child: PreviewImagesTaken(imageList: imageList),
                    ),
                    Expanded(
                      child: PredictCameraPreview(controller: controller),
                    ),
                  ],
                ),
                // ......................................................buttons
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 150,
                    color: const Color.fromARGB(179, 35, 151, 60),
                    padding: const EdgeInsets.only(top: 5, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xff465362),
                          ),
                          onPressed: () {
                            getImages();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(Icons.image),
                              const SizedBox(width: 10),
                              Text(
                                'gallery'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white, // Border color
                                width: 5.0, // Border width
                              ),
                            ),
                            child: IconButton(
                              iconSize: 70,
                              color: Colors.white,
                              onPressed: () {
                                takeImage();
                              },
                              icon: const Icon(
                                Icons.camera,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xff465362),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (BuildContext context) {
                                    return ConfirmIdentifyScreen(
                                      imageList: imageList,
                                    );
                                  }),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'identify'.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black,
            ),
          ),
        if (_isLoading)
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a Leaf Image ${notALeafImg.toString()}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  const SpinKitSquareCircle(
                    color: Color.fromRGBO(43, 219, 60, 1),
                    // trackColor: Color.fromARGB(255, 89, 254, 34),
                    // waveColor: Color.fromARGB(255, 16, 104, 4),
                    size: 100.0,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
