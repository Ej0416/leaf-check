import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leafcheck_project_v2/screeens/dash_board/dashboard_screen.dart';
import 'package:leafcheck_project_v2/styles/font_styles.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';

import '../../../services/firebase_helper.dart';
import 'result_card.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.imageList,
  });

  final List<XFile> imageList;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? uid = FirebaseHelper.getCurrentUserId();
  late List<XFile> passedImages = [];
  late List _result;
  late List imageQue = [];
  late List allResult = [];
  late List predictedLabels = [];
  late List predictedConf = [];
  late int healthy = 0;
  late int invalid = 0;
  late int anthrachnose = 0;
  late int leafspot = 0;
  late int earlyBlight = 0;

  bool isProcessing = false;
  bool isDone = false;

  CustomFontStyles fontStyles = CustomFontStyles();

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/tflite_model/tf_lite_model.tflite",
      labels: "assets/tflite_model/labels.txt",
    );
  }

  predict() async {
    while (imageQue.isNotEmpty) {
      var file = imageQue.removeAt(0);
      var res = await Tflite.runModelOnImage(
        path: file.path,
      );
      setState(() {
        _result = res!;
        allResult.add(_result[0]);
      });
      debugPrint(_result[0].toString());
    }
    isProcessing = false;
  }

  predictImage() async {
    for (var i = 0; i < passedImages.length; i++) {
      imageQue.add(passedImages[i]);
      if (!isProcessing) {
        debugPrint('starting predictions..............');
        isProcessing = true;
        await predict();
      }
    }
    for (var i = 0; i < allResult.length; i++) {
      String name = '';
      debugPrint(allResult[i]["label"].toString());
      switch (allResult[i]["label"].toString()) {
        case 'early-blight':
          name = 'Early Blight';
          earlyBlight++;
          break;
        case 'leaf-spot':
          name = 'Leaf Spot';
          leafspot++;
          break;
        case 'anthracnose':
          name = 'Anthracnose';
          anthrachnose++;
          break;
        case 'healthy':
          name = 'Healthy';
          healthy++;
          break;
        case 'unknown':
          name = 'Unknown';
          invalid++;
          break;
        default:
      }
      predictedLabels.add(name);
      predictedConf.add(allResult[i]["confidence"]);
      debugPrint("all results => ${allResult[i]["confidence"].runtimeType}");
    }
    debugPrint('finishing predictions..............');
    debugPrint(allResult.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    addRecentData();
    setState(() {
      isDone = true;
    });
    debugPrint('finishing predictions..............$isDone');
  }

  addRecentData() {
    final CollectionReference recents =
        FirebaseFirestore.instance.collection('recents_identification');

    recents.add({
      'userId': uid,
      'healthy': healthy,
      'leafSpot': leafspot,
      'earlyBlight': earlyBlight,
      'anthracnose': anthrachnose,
      'date': FieldValue.serverTimestamp(),
    }).then((value) {
      debugPrint('Data added Succefully');
    }).catchError((error) {
      debugPrint('Failed to add recent data');
    });
  }

  @override
  void initState() {
    debugPrint("Image list lengt: ${widget.imageList.length.toString()}");
    loadModel();
    passedImages = List.from(widget.imageList);
    predictImage();
    super.initState();
  }

  @override
  void dispose() {
    passedImages.clear();
    imageQue.clear();
    allResult.clear();
    predictedConf.clear();
    predictedLabels.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              "Results",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.green.shade400,
            elevation: 1,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const DashbardScreen();
                }));
              },
            ),
          ),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    // scrollDirection: Axis.horizontal,
                    itemCount: passedImages.length,
                    itemBuilder: (context, index) {
                      return ResultCard(
                        img: passedImages[index],
                        predictionconf: predictedConf.isNotEmpty
                            ? "${(predictedConf[index] * 100).toStringAsFixed(2)} %"
                            : "",
                        predictionCond: predictedLabels.isNotEmpty
                            ? predictedLabels[index].toString()
                            : "",
                        fontStyles: fontStyles,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isDone)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.black,
            ),
          ),
        if (!isDone)
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Loading..Stay Put...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 50,
                      animation: false,
                      lineHeight: 30.0,
                      animationDuration: 2000,
                      percent: allResult.length / passedImages.length,
                      center: Text(
                        "${((allResult.length / passedImages.length) * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      barRadius: const Radius.circular(20),
                      progressColor: Colors.green.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
