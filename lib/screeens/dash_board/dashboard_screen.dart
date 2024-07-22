import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:leafcheck_project_v2/screeens/toPDF/to_pdf.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../services/firebase_helper.dart';
import '../../services/login_out_user.dart';
import '../../styles/font_styles.dart';
import '../predict_image/results/bar_graph/bar_graph.dart';
import 'home/predict_yield_widget.dart';
import 'home/recents.dart';
import 'home/take_pick_widget.dart';

final userRef = FirebaseFirestore.instance.collection('users');

class DashbardScreen extends StatefulWidget {
  const DashbardScreen({super.key});

  @override
  State<DashbardScreen> createState() => _DashbardScreenState();
}

class _DashbardScreenState extends State<DashbardScreen> {
  CustomFontStyles fonts = CustomFontStyles();
  String? uid = FirebaseHelper.getCurrentUserId();
  String username = '';

  late double avgTemp = 0;
  late double avgHumidity = 0;
  late double avgRain1h = 0;
  late int maxNumber = 0;

  late List diseases = ['Leaf Spot', 'Early Blight', 'Anthracnose'];
  late List<double> probability = [0.0, 0.0, 0.0];

  bool isSwap = false;
  List<Map<String, dynamic>> recents = [];
  List<Map<String, dynamic>> recentYield = [];
  List<String> dateList = [];
  List<String> yieldList = [];
  Map<DateTime, Map<String, int>> totalsByDate = {};

  getDates() {
    for (var i = 0; i < recentYield.length; i++) {
      Timestamp t = recentYield[i]['date'];
      int daysToAdd = recentYield[i]['interval'] ?? 1;
      DateTime d = t.toDate();
      d = d.add(Duration(days: daysToAdd));
      String date = DateFormat.MMMd().format(d);
      setState(() {
        dateList.add(date);
        yieldList.add(recentYield[i]['yield']);
      });
    }

    setState(() {
      List<int> intList = yieldList.map((str) => int.parse(str)).toList();
      maxNumber = intList.reduce(
          (currentMax, number) => currentMax > number ? currentMax : number);
    });

    debugPrint(maxNumber.toString());
  }

  Future getRecents() async {
    try {
      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('recents_identification')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();
      // .where('userId', isEqualTo: uid)
      var query = FirebaseFirestore.instance
          .collection('recent_yield_prediction')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(5); // Retrieve the last 96(4 days) entries

      var querySnapshot = await query.get();
      var docs = querySnapshot.docs;

      for (QueryDocumentSnapshot doc in qs.docs) {
        setState(() {
          recents.add(doc.data() as Map<String, dynamic>);
        });
      }

      for (QueryDocumentSnapshot doc2 in docs) {
        setState(() {
          recentYield.add(doc2.data() as Map<String, dynamic>);
        });
      }
      getDates();
    } catch (e) {
      debugPrint('Erro fetfching documents: $e');
    }
    getTotalByDate();
    debugPrint('recents function run successfully');
  }

  getTotalByDate() {
    for (var item in recents) {
      DateTime date = DateTime(item['date']!.toDate().year,
          item['date']!.toDate().month, item['date']!.toDate().day);
      Map<String, int> totals = totalsByDate[date] ?? {};
      item.forEach((key, value) {
        if (key != 'date' && key != 'userId') {
          totals[key] = (totals[key] ?? 0) + (value as int? ?? 0);
        }
      });

      totalsByDate[date] = totals;
    }

    debugPrint('test function run successfully');
  }

  getUsername() async {
    final DocumentSnapshot doc = await userRef.doc(uid).get();

    setState(() {
      username = doc['name'];
    });
  }

  Future getLastEntries() async {
    var query = FirebaseFirestore.instance
        .collection('daily_weather')
        .orderBy('date', descending: true)
        .limit(168); // Retrieve the last 96(4 days) entries

    var querySnapshot = await query.get();
    var docs = querySnapshot.docs;

    double temp = 0;
    double humidity = 0;
    double rain1h = 0;
    double count = 0;

    for (var doc in docs) {
      var data = doc.data();
      temp = temp + data['temp'];
      humidity = humidity + data['humidity'];
      rain1h = rain1h + data['rain'];
      count++;
    }

    setState(() {
      avgTemp = temp / count;
      avgHumidity = humidity / count;
      avgRain1h = rain1h / count;
    });

    forecastLeafSpot(avgRain1h.toString());
    forecastEarlyBlight(avgRain1h.toString(), avgHumidity.toString());
    forecastAnthrachnose(
        avgTemp.toString(), avgHumidity.toString(), avgRain1h.toString());

    debugPrint("Get last entires ran fine");
    debugPrint(
        "${avgTemp.toString()}, ${avgHumidity.toString()}, ${avgRain1h.toString()}");
  }

  Future forecastLeafSpot(rain1h) async {
    try {
      const apiUrl = 'https://elnesjan.pythonanywhere.com/leaf_spot';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'rain1h': rain1h,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          probability[0] = double.parse(data["likelihood"].toStringAsFixed(2));
        });
      } else {
        debugPrint(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future forecastEarlyBlight(rain1h, hum) async {
    try {
      const apiUrl = 'https://elnesjan.pythonanywhere.com/early_blight';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'rain1h': rain1h,
          'humidity': hum,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          probability[1] = double.parse(data["likelihood"].toStringAsFixed(2));
        });
      } else {
        debugPrint(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future forecastAnthrachnose(temp, humidity, rain1h) async {
    try {
      const apiUrl = 'https://elnesjan.pythonanywhere.com/anthracnose';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'temp': temp,
          'humidity': humidity,
          'rain1h': rain1h,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          probability[2] = double.parse(data["likelihood"].toStringAsFixed(2));
        });
      } else {
        debugPrint(
            'Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    getUsername();
    getRecents();
    getLastEntries();
    super.initState();
  }

  @override
  void dispose() {
    isSwap;
    recents;
    recentYield;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 24),
                width: (MediaQuery.of(context).size.width),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin:
                          const EdgeInsets.only(left: 0, top: 10, bottom: 10),
                      child: Text(
                        'Likelihood of Disease Occurance \n(Disease Forecast)',
                        style: fonts.titleFont,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    CarouselSlider.builder(
                      itemCount: 3,
                      options: CarouselOptions(
                        height: 120,
                        viewportFraction: .65,
                        autoPlay: true,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return forecastContainers(
                            diseases[index], probability[index]);
                      },
                    ),
                  ],
                ),
              ),
              // const HomeScreen(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSwap = !isSwap;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_circle_left_rounded,
                            size: 40,
                            color: Color(0xff465362),
                          ),
                        ),
                        Text(
                          isSwap
                              ? 'Yield Prediction'
                              : "Disease Identification",
                          style: fonts.titleFont,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSwap = !isSwap;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_circle_right_rounded,
                            size: 40,
                            color: Color(0xff465362),
                          ),
                        )
                      ],
                    ),
                    // take pic and stuff
                    isSwap
                        ? const PredictYieldWidget()
                        : const TakePickWidget(),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Container(
                      // color: Colors.amber,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          debugPrint(uid);
                        },
                        child: Text(
                          isSwap
                              ? "Possible Yield (in Kg)"
                              : "Recent Identification Data",
                          style: fonts.titleFont,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isSwap
                      ? recentYield.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(
                                  bottom: 60, left: 20, right: 20),
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 10),
                              height: 192,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF000000),
                                    offset: Offset(-1, 0),
                                    blurRadius: 13,
                                    spreadRadius: -7,
                                  ),
                                ],
                              ),
                              child: ResultBarGraph(
                                maxNum: maxNumber,
                                dateList: dateList,
                                quantityPerClass: yieldList
                                    .map((item) => double.tryParse(item) ?? 0.0)
                                    .toList(),
                              ),
                            )
                          : Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(10),
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF000000),
                                    offset: Offset(-1, 0),
                                    blurRadius: 13,
                                    spreadRadius: -7,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 80,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 50,
                                    child: Icon(
                                      Icons.folder_off,
                                      size: 50,
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                ),
                              ),
                            )
                      : totalsByDate.isNotEmpty
                          ? CarouselSlider.builder(
                              itemCount: totalsByDate.length,
                              options: CarouselOptions(
                                height: 250,
                                initialPage: (totalsByDate.length / 2).ceil(),
                                enlargeCenterPage: true,
                                viewportFraction: 1,
                              ),
                              itemBuilder: (context, index, realIndex) {
                                MapEntry<DateTime, Map<String, int>> entry =
                                    totalsByDate.entries.toList()[index];

                                // Formatting the date
                                String date = DateFormat.yMMMd()
                                    .add_jm()
                                    .format(entry.key);

                                // Extracting values from the inner map
                                int anthracnose =
                                    entry.value['anthracnose'] ?? 0;
                                int earlyBlight =
                                    entry.value['earlyBlight'] ?? 0;
                                int leafSpot = entry.value['leafSpot'] ?? 0;
                                int healthy = entry.value['healthy'] ?? 0;
                                return Recents(
                                  anthrachnose: anthracnose.toString(),
                                  earlyBlight: earlyBlight.toString(),
                                  leafSpot: leafSpot.toString(),
                                  healthy: healthy.toString(),
                                  date: date,
                                );
                              },
                            )
                          : Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(10),
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF000000),
                                    offset: Offset(-1, 0),
                                    blurRadius: 13,
                                    spreadRadius: -7,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 80,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 50,
                                    child: Icon(
                                      Icons.folder_off,
                                      size: 50,
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                ),
                              ),
                            )
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          debugPrint(uid);
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.only(top: 30),
                color: Colors.green.shade300,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Hello, $username',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor:
                              const Color.fromARGB(255, 217, 73, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          logoutUser(context);
                        },
                        child: const Text('Logout'),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor:
                              const Color.fromARGB(255, 40, 170, 217),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          debugPrint('test');
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return const ToPDF();
                          }));
                        },
                        child: const Text('Print All Data'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: const Color(0xff465362),
        label: const Text('Menu'),
        icon: const Icon(
          Icons.menu,
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Container forecastContainers(name, probability) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(name),
          // const SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 10.0,
            animation: true,
            percent: probability / 100,
            center: Text(
              "$probability%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            footer: Text(
              "$name Probability",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
                color: Colors.white,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  var style = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  var style2 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
