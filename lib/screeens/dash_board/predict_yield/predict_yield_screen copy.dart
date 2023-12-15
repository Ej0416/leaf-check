import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:leafcheck_project_v2/screeens/dash_board/predict_yield/current_weather_widget.dart';

import '../../../services/firebase_helper.dart';

class PredictYieldScreenCopy extends StatefulWidget {
  const PredictYieldScreenCopy({super.key});

  @override
  State<PredictYieldScreenCopy> createState() => _PredictYieldScreenCopyState();
}

class _PredictYieldScreenCopyState extends State<PredictYieldScreenCopy> {
  late String? uid = '';
  double avgTemp = 0;
  double avgTempMin = 0;
  double avgTempMax = 0;
  double avgPressure = 0;
  double avgHumidity = 0;
  double avgWindSpeed = 0;
  double avgCloudsAll = 0;
  double avgRain1h = 0;
  double totalRain1h = 0;

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
          estimatedYield =
              double.parse(data["estimated_yield"].first.toString());
          Navigator.pop(context);
          bottomModal();
        });
        debugPrint('Estimated Yield: ${estimatedYield.toStringAsFixed(0)}');
      } else {
        debugPrint(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<dynamic> bottomModal() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.green.shade300,
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Is the Prediction Good?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor:
                            const Color.fromARGB(255, 40, 158, 217),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        addRecentYieldData();
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.thumb_up),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: const Color.fromARGB(255, 217, 73, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          // useRootNavigator: false,
                          // barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Enter Actual Yield'),
                              content: TextField(
                                controller: estimatedYieldCorrection,
                                decoration: const InputDecoration(
                                  hintText: 'eggplant yield here...',
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    debugPrint(estimatedYieldCorrection.text);
                                    setState(() {
                                      estimatedYield = double.parse(
                                          estimatedYieldCorrection.text);
                                    });
                                    addRecentYieldData();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        // Navigator.pop(context);
                      },
                      child: const Icon(Icons.thumb_down),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future getLastEntries() async {
    var query = FirebaseFirestore.instance
        .collection('daily_weather')
        .orderBy('date', descending: true)
        .limit(72); // Retrieve the last 96(4 days) entries

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
    });
  }

  addRecentYieldData() {
    final CollectionReference recents =
        FirebaseFirestore.instance.collection('recent_yield_prediction');

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
    }).then((value) {
      updateModel();
      debugPrint('Data added Succefully!');
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Data Saved Successfully'),
            content: Text(
              'Each saved data would help to further enhance the yield prediction capability of this app',
              textAlign: TextAlign.justify,
            ),
          );
        },
      );
    }).catchError((error) {
      debugPrint('Failed to add recent data');
    });
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

  test() {
    predictYield(
      '27',
      '26',
      '28',
      '1010',
      '85',
      '1',
      '90',
      '.55',
    );
  }

  predctYield(temp, tempMin, tempMax, pressure, humidity, widnSpeed, cloudsall,
      rain1h) {}

  @override
  void initState() {
    getLastEntries();
    uid = FirebaseHelper.getCurrentUserId();
    super.initState();
  }

  @override
  void dispose() {
    estimatedYieldCorrection;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = 90;
    double h = 70;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Predict Yield '),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
                      const Text(
                        'Estimated Yield',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CircleAvatar(
                        backgroundColor: Colors.green.shade400,
                        radius: 100,
                        child: Text(
                          ' ${estimatedYield.toStringAsFixed(0)} kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
              const SizedBox(height: 10),
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
                      onPressed: () async {
                        debugPrint(
                            'this is the total rain value: ${totalRain1h.toStringAsFixed(0)}');
                        // test();
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
                        // updateModel();
                      },
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
