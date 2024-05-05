import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leafcheck_project_v2/screeens/dash_board/dashboard_screen.dart';
import 'package:leafcheck_project_v2/screeens/predict_image/take_images/preview_images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';

import 'camera_preview.dart';
import 'confimr_identify.dart';

class TakePicScreen extends StatefulWidget {
  const TakePicScreen({
    super.key,
  });

  @override
  State<TakePicScreen> createState() => _TakePicScreenState();
}

class _TakePicScreenState extends State<TakePicScreen> {
  // late ImageListModel imageList;
  late List<XFile> imageList = [];
  late List<CameraDescription> cameras;
  CameraController? controller;
  File? image2;
  XFile? image;
  final _picker = ImagePicker();
  late bool _isLoading = false;
  int notALeafImg = 0;
  late int numOfImgs = 0;

  late double _minAvailableZoom = 1.0;
  late double _maxAvailableZoom = 1.0;
  late double _currentZoomLevel = 1.0;

  late double _currentExposureOffset = 0.0;
  late double _minAvailableExposureOffset = 0.0;
  late double _maxAvailableExposureOffset = 0.0;

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller = CameraController(cameras[0], ResolutionPreset.medium);

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          controller!
              .getMaxZoomLevel()
              .then((value) => _maxAvailableZoom = value);
          controller!
              .getMinZoomLevel()
              .then((value) => _minAvailableZoom = value);
          controller!
              .getMinExposureOffset()
              .then((value) => _minAvailableExposureOffset = value);

          controller!
              .getMaxExposureOffset()
              .then((value) => _maxAvailableExposureOffset = value);
        });
      });
    } else {
      debugPrint("No Camera found");
    }
  }

  late final List _result = [];
  String confidence = '';
  String name = '';
  File? _image;

  loadModel() async {
    var result = await Tflite.loadModel(
      model: "assets/leaf_not/tf_lite_model.tflite",
      labels: "assets/leaf_not/labels.txt",
    );
  }

  predictFromCam(File file, XFile xfile) async {
    debugPrint(
        '-------------------------preiction start------------------------');
    try {
      var res = await Tflite.runModelOnImage(
        path: file.path,
      );

      setState(() {
        _result.add(res!);
        debugPrint('result lenght is: ${_result.length.toString()}');
        if (_result[_result.length - 1][0]['label'] == 'not_leaf') {
          debugPrint('the damn fucking Image is not a leaf');
          setState(() {
            notALeafImg += 1;
          });
        } else {
          debugPrint('Image is  a leaf');
          imageList.add(xfile);
          numOfImgs = imageList.length;
          _saveImageList();
        }
      });
    } catch (e) {
      debugPrint("there is an error: $e");
    }
  }

  predictFromGallery(File file, XFile xfile) async {
    debugPrint(
        '-------------------------preiction start------------------------');
    try {
      var res = await Tflite.runModelOnImage(
        path: file.path,
      );

      setState(() {
        _result.add(res!);

        debugPrint('res current index: ${res[0]['label']}');
        debugPrint(
            'result current index is:${_result[_result.length - 1][0]['label']}');

        if (res[0]['label'] == 'not_leaf') {
          debugPrint('the damn fucking Image is not a leaf');
          setState(() {
            notALeafImg += 1;
          });
          debugPrint('not a leaf count: $notALeafImg');
        } else {
          setState(() {
            imageList.add(xfile);
            numOfImgs = imageList.length;
            _saveImageList();
          });
          debugPrint('Image is  a leaf');
        }
      });
    } catch (e) {
      debugPrint("there is an error: $e");
    }
  }

  Future<void> _loadImageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      imageList = (prefs.getStringList('imageList') ?? [])
          .map((e) => XFile(e))
          .toList();
    });
  }

  Future<void> _saveImageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'imageList', imageList.map((e) => e.path).toList());
  }

  Future getImages() async {
    List<XFile>? xfilePick = await _picker.pickMultiImage(
        maxHeight: 650, maxWidth: 650, imageQuality: 90);
    try {
      if (xfilePick.isNotEmpty) {
        setState(() async {
          notALeafImg = 0;
          _isLoading = true;
          for (var i = 0; i < xfilePick.length; i++) {
            _image = File(xfilePick[i].path);
            await predictFromGallery(_image!, xfilePick[i]);
            debugPrint(_isLoading.toString());
          }

          if (notALeafImg > 0) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Not a Leaf'),
                  content: Text(
                    '$notALeafImg image/s are not an image of a leaf. Only images of leaves are recognizable by the app',
                    textAlign: TextAlign.justify,
                  ),
                );
              },
            );
          }

          _isLoading = false;
          debugPrint(_isLoading.toString());
          debugPrint("nont a leaf count: $notALeafImg");
          xfilePick.clear();
          // imageList.addAll(xfilePick);
        });
      } else {
        debugPrint("Nothing is selected");
      }
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
          debugPrint(_isLoading.toString());

          if (image != null) {
            setState(() async {
              _image = File(image!.path);
              await predictFromCam(_image!, image!);
              await Future.delayed(const Duration(milliseconds: 650));
              setState(() {
                _isLoading = false;
                if (notALeafImg > 0) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text('Not a Leaf'),
                        content: Text(
                          'The image taken is not a leaf. Only images of leaves are recognizable by the app',
                          textAlign: TextAlign.justify,
                        ),
                      );
                    },
                  );
                }
                notALeafImg = 0;
              });
              debugPrint(_isLoading.toString());
            });
          }
        }
      }
      debugPrint("${imageList.length}");
      debugPrint("The path ${image!.path}");
    } catch (e) {
      debugPrint("$e"); //show error
    }
  }

  void intructionsdialouge(BuildContext context) {
    // 80% of screen height

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 30),
          titlePadding: const EdgeInsets.all(0),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Container(
            color: Colors.green.shade400,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: const Text(
              'Reminder:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          content: SizedBox(
            height: 350,
            // color: Colors.amber,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                reminderContent('Image taken should \nfocus on the leaf',
                    "assets/home/sample.jpg", TextDirection.ltr),
                reminderContent('Blurry images will be \nrejected by the app',
                    "assets/home/blurry.jpg", TextDirection.ltr),
                reminderContent(
                    'Small size images might \nalso be rejected or be \nindentified incorrectly',
                    "assets/home/small_img.JPG",
                    TextDirection.ltr),
              ],
            ),
          ),
        );
      },
    );
  }

  Row reminderContent(msg, img, dynamic direction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: direction,
      children: [
        Text(
          msg,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.justify,
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              border: Border.all(
            width: 1,
            color: Colors.black45,
          )),
          child: Image(
            image: AssetImage(img),
            fit: BoxFit.fill,
          ),
        )
      ],
    );
  }

  // for tap to focus
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  Future<void> _onTap(TapUpDetails details) async {
    if (controller!.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      print(x);
      print(y);

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * controller!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);
      print("point : $point");

      // Manually focus
      await controller!.setFocusPoint(point);

      // Manually set light exposure
      controller!.setExposurePoint(point);

      setState(() {
        Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    }
  }

  @override
  void initState() {
    loadModel();
    loadCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      intructionsdialouge(context);
    });
    _loadImageList();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    imageList;
    super.dispose();
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
            title: const Text(
              "Take Leaf Image",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              Row(
                children: [
                  Text(
                    'Images: ${numOfImgs.toString()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ],
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: GestureDetector(
              onTapUp: (details) {
                _onTap(details);
              },
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
                            onPressed: () async {
                              await getImages();
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: brightSlider(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 30,
                      color: Colors.transparent,
                      margin: const EdgeInsets.only(bottom: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: zoomSlider(),
                    ),
                  ),
                  if (showFocusCircle)
                    Positioned(
                      top: y - 20,
                      left: x - 20,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
                      ),
                    )
                ],
              ),
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
                children: const [
                  Text(
                    "Loading...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                    ),
                  ),
                  // const SizedBox(height: 100),
                  SizedBox(
                    height: 200,
                    child: SpinKitSquareCircle(
                      color: Color.fromRGBO(43, 219, 60, 1),
                      // trackColor: Color.fromARGB(255, 89, 254, 34),
                      // waveColor: Color.fromARGB(255, 16, 104, 4),
                      size: 100.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Container brightSlider() {
    return Container(
      height: 350,
      margin: const EdgeInsets.only(bottom: 20, right: 10),
      child: Column(
        children: [
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xff465362),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${_currentExposureOffset.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SizedBox(
                height: 40,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xff465362),
                    overlayColor: const Color(0xff465362),
                  ),
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: const Color(0xff465362),
                    onChanged: (value) async {
                      setState(() {
                        _currentExposureOffset = value;
                      });
                      await controller!.setExposureOffset(value);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row zoomSlider() {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xff465362),
              overlayColor: const Color(0xff465362),
            ),
            child: Slider(
              value: _currentZoomLevel,
              min: _minAvailableZoom,
              max: _maxAvailableZoom,
              activeColor: const Color(0xff465362),
              onChanged: (value) async {
                setState(() {
                  _currentZoomLevel = value;
                });
                await controller!.setZoomLevel(value);
              },
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xff465362),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${_currentZoomLevel.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
