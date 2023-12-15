import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import '../../../services/firebase_helper.dart';

class PredictYieldScreen extends StatefulWidget {
  const PredictYieldScreen({super.key});

  @override
  State<PredictYieldScreen> createState() => _PredictYieldScreenState();
}

class _PredictYieldScreenState extends State<PredictYieldScreen> {
  String? uid = FirebaseHelper.getCurrentUserId();

  double avgTemp = 0;
  double avgTempMin = 0;
  double avgTempMax = 0;
  double avgPressure = 0;
  double avgHumidity = 0;
  double avgWindSpeed = 0;
  double avgCloudsAll = 0;
  double avgRain1h = 0;

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
          // addRecentYieldData();
          // updateModel();
          setState(() {
            Navigator.pop(context);
          });
        });
        debugPrint('Estimated Yield: ${estimatedYield.toStringAsFixed(0)}');
      } else {
        debugPrint(
            'Failed to get prediction. Status code: ${response.statusCode}');
        setState(() {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future getLastEntries() async {
    var query = FirebaseFirestore.instance
        .collection('daily_weather')
        .orderBy('date', descending: true)
        .limit(76); // Retrieve the last 24 entries

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

    setState(() {
      avgTemp = temp / count;
      avgTempMin = tempMin / count;
      avgTempMax = tempMax / count;
      avgPressure = pressure / count;
      avgHumidity = humidity / count;
      avgWindSpeed = windSpeed / count;
      avgCloudsAll = cloudsAll / count;
      avgRain1h = rain1h / count;
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
      debugPrint('Data added Succefully');
    }).catchError((error) {
      debugPrint('Failed to add recent data');
    });
  }

  Future updateModel() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('recent_yield_prediction')
        .get();

    List<Map<String, dynamic>> doc = qs.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data.remove('date');

      return data;
    }).toList();

    debugPrint(doc.toString());

    final apiUrl =
        Uri.parse('http://chunchunmaru.pythonanywhere.com/update_model');

    try {
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
    getLastEntries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Predict Yield'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${estimatedYield.toStringAsFixed(0)} kg',
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
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
              },
              child: const Text('Predict Yield'),
            ),
          ],
        ),
      ),
    );
  }
}
