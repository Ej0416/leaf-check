import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:leafcheck_project_v2/screeens/dash_board/predict_yield/current_weather_widget.dart';

import '../../../services/firebase_helper.dart';
import '../dashboard_screen.dart';

class PredictYieldScreenCopy extends StatefulWidget {
  const PredictYieldScreenCopy({super.key});

  @override
  State<PredictYieldScreenCopy> createState() => _PredictYieldScreenCopyState();
}

class _PredictYieldScreenCopyState extends State<PredictYieldScreenCopy> {
  String? uid = FirebaseHelper.getCurrentUserId();
  double avgTemp = 0;
  double avgTempMin = 0;
  double avgTempMax = 0;
  double avgPressure = 0;
  double avgHumidity = 0;
  double avgWindSpeed = 0;
  double avgCloudsAll = 0;
  double avgRain1h = 0;
  double totalRain1h = 0;

  int predictedYieldDate = 0;

  double penalty = 0;
  double anthracnosePenalPercentage = 0;
  double leafspotPercentage = 0;
  double earlyblightPenalPercentage = 0;

  TextEditingController estimatedYieldCorrection = TextEditingController();

  late double estimatedYield = 0;

  Future<void> predictYield(temp, tempMin, tempMax, pressure, humidity,
      widnSpeed, cloudsall, rain1h) async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: SpinKitSquareCircle(
          color: Color.fromRGBO(43, 219, 60, 1),
          // trackColor: Color.fromARGB(255, 89, 254, 34),
          // waveColor: Color.fromARGB(255, 16, 104, 4),
          size: 100.0,
        ),
      ),
    );
    try {
      const apiUrl = 'https://chunchunmaru.pythonanywhere.com/yield_prediction';
      final response = await http.post(Uri.parse(apiUrl), body: {
        'temp': temp,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'pressure': pressure,
        'humidity': humidity,
        'wind_speed': widnSpeed,
        'clouds_all': cloudsall,
        'rain1h': rain1h,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          double temp =
              double.parse(data["estimated_yield"].first.toString()) * 1.75;
          double deduc = temp * penalty;
          estimatedYield = temp -= deduc;
          debugPrint("this is the temp: ${temp.toString()}");
          debugPrint("this is the deduc: ${deduc.toString()}");
          Navigator.pop(context);
          addRecentYieldData();
        });
        debugPrint('Estimated Yield: ${estimatedYield.toString()}');
      } else {
        debugPrint(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future getLastEntries(int days) async {
    int limit = days * 24;
    var query = FirebaseFirestore.instance
        .collection('daily_weather')
        .orderBy('date', descending: true)
        .limit(limit);

    var querySnapshot = await query.get();
    var docs = querySnapshot.docs;

    double temp = 0;
    double tempMin = 0;
    double tempMax = 0;
    double pressure = 0;
    double humidity = 0;
    double windSpeed = 0;
    double cloudsAll = 0;
    double rain1h = 0;
    double count = 0;

    for (var doc in docs) {
      var data = doc.data();
      temp = temp + data['temp'];
      tempMin = tempMin + data['temp_min'];
      tempMax = tempMax + data['temp_max'];
      pressure = pressure + data['pressure'];
      humidity = humidity + data['humidity'];
      windSpeed = windSpeed + data['wind_speed'];
      cloudsAll = cloudsAll + data['clouds_all'];
      rain1h = rain1h + data['rain'];
      count++;
    }

    debugPrint('this is the total rain value: ${rain1h.toString()}');

    setState(() {
      avgTemp = temp / count;
      avgTempMin = tempMin / count;
      avgTempMax = tempMax / count;
      avgPressure = pressure / count;
      avgHumidity = humidity / count;
      avgWindSpeed = windSpeed / count;
      avgCloudsAll = cloudsAll / count;
      avgRain1h = rain1h / count;
      totalRain1h = rain1h;
      predictedYieldDate = days;
    });
  }

  rangeSetter(double total) {
    double deduction = 0;
    if (total <= 10 && total > 0) {
      deduction = .01;
    } else if (total <= 20 && total >= 10) {
      deduction = .02;
    } else if (total <= 30 && total >= 20) {
      deduction = .03;
    } else if (total <= 40 && total >= 30) {
      deduction = .04;
    } else if (total <= 50 && total >= 40) {
      deduction = .05;
    } else if (total <= 60 && total >= 50) {
      deduction = .06;
    } else if (total <= 70 && total >= 60) {
      deduction = .07;
    } else if (total <= 80 && total >= 70) {
      deduction = .08;
    } else if (total <= 90 && total >= 80) {
      deduction = .09;
    } else if (total <= 100 && total >= 90) {
      deduction = .10;
    }

    return deduction;
  }

  Future getRecentDiseaseIdentifications(days) async {
    DateTime end = DateTime.now();
    DateTime start = end.subtract(Duration(days: days));
    var query = FirebaseFirestore.instance
        .collection('recents_identification')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('userId', isEqualTo: uid);

    var querySnapshot = await query.get();
    var docs = querySnapshot.docs;

    double anthracnose = 0;
    double leafSpot = 0;
    double earlyBlight = 0;

    for (var doc in docs) {
      var data = doc.data();
      anthracnose = anthracnose + data['anthracnose'];
      leafSpot = leafSpot + data['leafSpot'];
      earlyBlight = earlyBlight + data['earlyBlight'];
    }

    debugPrint(
        "Antrachnose: $anthracnose, LeafSpot: $leafSpot. EarlyBlight: $earlyBlight");

    setState(() {
      penalty = (rangeSetter(anthracnose) +
          rangeSetter(leafSpot) +
          rangeSetter(earlyBlight));

      anthracnosePenalPercentage = rangeSetter(anthracnose) * 100;
      leafspotPercentage = rangeSetter(leafSpot) * 100;
      earlyblightPenalPercentage = rangeSetter(earlyBlight) * 100;

      debugPrint("Penalty: $penalty");
      debugPrint(
          "Penalty: $anthracnosePenalPercentage, $leafspotPercentage, $earlyblightPenalPercentage");
    });
  }

  addRecentYieldData() {
    final CollectionReference recents =
        FirebaseFirestore.instance.collection('recent_yield_prediction');

    if (estimatedYield > 0) {
      recents.add({
        'userId': uid,
        'date': FieldValue.serverTimestamp(),
        'temp': avgTemp.round(),
        'temp_min': avgTempMin.round(),
        'temp_max': avgTempMax.round(),
        'pressure': avgPressure.round(),
        'humidity': avgHumidity.round(),
        'wind_speed': avgWindSpeed.round(),
        'clouds_all': avgCloudsAll.round(),
        'rain_1h': avgRain1h.toStringAsFixed(2),
        'yield': estimatedYield.toStringAsFixed(0),
        'interval': predictedYieldDate,
      }).then((value) {
        updateModel();
        debugPrint('Data added Succefully!');
      }).catchError((error) {
        debugPrint('Failed to add recent data');
      });
    }
  }

  Future updateModel() async {
    final apiUrl =
        Uri.parse('http://chunchunmaru.pythonanywhere.com/update_model');

    try {
      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('recent_yield_prediction')
          .get();

      List<Map<String, dynamic>> doc = qs.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data.remove('date');

        return data;
      }).toList();

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(doc),
      );

      if (response.statusCode == 200) {
        debugPrint('Server Response: ${response.body}');
      } else {
        debugPrint('Operation failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    debugPrint('everythiongs should reload blah blah blahs');
    // getRecentDiseaseIdentifications();
    uid = FirebaseHelper.getCurrentUserId();
    super.initState();
  }

  @override
  void dispose() {
    estimatedYieldCorrection;
    super.dispose();
  }

  final List<DropdownMenuItem<int>> dropdownMenuEntries = [
    const DropdownMenuItem(value: 2, child: Text('2 Days')),
    const DropdownMenuItem(value: 3, child: Text('3 Days')),
    const DropdownMenuItem(value: 4, child: Text('4 Days')),
    const DropdownMenuItem(value: 5, child: Text('5 Days')),
    const DropdownMenuItem(value: 6, child: Text('6 Days')),
    const DropdownMenuItem(value: 7, child: Text('7 Days')),
  ];

  int selectedDays = 0;

  @override
  Widget build(BuildContext context) {
    TextStyle title = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      // fontWeight: FontWeight.w400,
    );
    TextStyle disease = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      // fontWeight: FontWeight.w400,
    );
    TextStyle value = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xff465362),
      // fontWeight: FontWeight.w400,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Predict Yield '),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return const DashbardScreen();
            }));
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Harvest Interval',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: DropdownButton(
                                underline: Container(
                                  height: 2,
                                  color: Colors.black54,
                                ),
                                hint: Text(
                                  '${selectedDays.toString()} days',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                items: dropdownMenuEntries,
                                // dropdownColor: Colors.green.shade400,
                                onChanged: (int? days) {
                                  setState(() {
                                    selectedDays = days ?? 0;
                                  });
                                  getRecentDiseaseIdentifications(days!);
                                  getLastEntries(days);
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 220,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 70,
                              child: Text(
                                ' ${estimatedYield.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                  color: Color(0xff465362),
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(left: 20),
                                // color: Colors.amber,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "Reductions",
                                      style: title,
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          // crossAxisAlignment:
                                          //     CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Anthracnose",
                                              style: disease,
                                            ),
                                            Text(
                                              "$anthracnosePenalPercentage %",
                                              style: value,
                                            ),
                                            Text(
                                              "Early Blight",
                                              style: disease,
                                            ),
                                            Text(
                                              "$earlyblightPenalPercentage %",
                                              style: value,
                                            ),
                                            Text(
                                              "Leaf Spot",
                                              style: disease,
                                            ),
                                            Text(
                                              "$leafspotPercentage %",
                                              style: value,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                'Average Weather for the Past 4 days',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              CurrentWEather(
                temp: avgTemp.round().toString(),
                tempMin: avgTempMin.round().toString(),
                tempMax: avgTempMax.round().toString(),
                pressure: avgPressure.round().toString(),
                humidity: avgHumidity.round().toString(),
                widnSpeed: avgWindSpeed.round().toString(),
                cloudsall: avgCloudsAll.round().toString(),
                rain1h: avgRain1h.toStringAsFixed(2),
              ),
              SizedBox(
                // color: Colors.amber,
                height: MediaQuery.of(context).size.height * .2,
                child: Center(
                  child: SizedBox(
                    width: 250,
                    height: 70,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: const Color(0xff465362),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: avgTemp != 0
                          ? () {
                              predictYield(
                                avgTemp.round().toString(),
                                avgTempMin.round().toString(),
                                avgTempMax.round().toString(),
                                avgPressure.round().toString(),
                                avgHumidity.round().toString(),
                                avgWindSpeed.round().toString(),
                                avgCloudsAll.round().toString(),
                                avgRain1h.toStringAsFixed(2),
                              );
                            }
                          : null,
                      child: const Text(
                        'Predict Yield',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
