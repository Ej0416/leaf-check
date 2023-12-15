import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  TextEditingController field1Controller = TextEditingController();
  TextEditingController field2Controller = TextEditingController();
  TextEditingController field3Controller = TextEditingController();
  TextEditingController field4Controller = TextEditingController();
  TextEditingController field5Controller = TextEditingController();

  getDates() {
    for (var i = 0; i < recentYield.length; i++) {
      Timestamp t = recentYield[i]['date'];
      DateTime d = t.toDate();
      String date = DateFormat.MMMd().format(d);
      setState(() {
        dateList.add(date);
        yieldList.add(recentYield[i]['yield']);
      });
    }

    setState(() {
      field1Controller.text = yieldList[0];
      field2Controller.text = yieldList[1];
      field3Controller.text = yieldList[2];
      field4Controller.text = yieldList[3];
      field5Controller.text = yieldList[4];

      List<int> intList = yieldList.map((str) => int.parse(str)).toList();
      maxNumber = intList.reduce(
          (currentMax, number) => currentMax > number ? currentMax : number);
    });

    debugPrint(maxNumber.toString());
  }

  updateYields() {
    var query = FirebaseFirestore.instance
        .collection('recent_yield_prediction')
        .orderBy('date', descending: true)
        .limit(5);

    query.get().then((querySnapshot) {
      int index = 0;
      for (var doc in querySnapshot.docs) {
        String documentID = doc.id;
        String yieldValue = yieldList[index];

        FirebaseFirestore.instance
            .collection('recent_yield_prediction')
            .doc(documentID)
            .update({
          'yield': yieldValue,
        }).then((_) {
          debugPrint('Yield updated successfully in document $documentID');
        }).catchError((error) {
          debugPrint('Error updating yield: $error');
        });

        index++; // Move to the next yield value
      }
    }).catchError((error) {
      debugPrint('Error getting documents: $error');
    });
  }

  Future getRecents() async {
    try {
      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('recents_identification')
          .get();
      // .where('userId', isEqualTo: uid)
      var query = FirebaseFirestore.instance
          .collection('recent_yield_prediction')
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
    // return recents;
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
    field1Controller;
    field2Controller;
    field3Controller;
    field4Controller;
    field5Controller;
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
                      margin:
                          const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          debugPrint((probability[0] / 100).toString());
                        },
                        child: Text(
                          'Disease Forecast',
                          style: fonts.titleFont,
                        ),
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
                        Text(
                          isSwap ? 'Predict Yield ' : "Tend to your Crop",
                          style: fonts.titleFont,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSwap = !isSwap;
                            });
                          },
                          icon: const Icon(
                            Icons.swap_horizontal_circle_sharp,
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
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          debugPrint(recentYield[4]['date'].toString());
                          debugPrint(dateList.toString());
                          debugPrint(recentYield.length.toString());
                        },
                        child: Text(
                          isSwap
                              ? "Recent Yield Data"
                              : "Recent Identification Data",
                          style: fonts.titleFont,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isSwap
                      ? recentYield.isNotEmpty
                          ? GestureDetector(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Edit Recent Yields',
                                        textAlign: TextAlign.center,
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: field1Controller,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      dateList[0].toString()),
                                            ),
                                            TextFormField(
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: field2Controller,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      dateList[1].toString()),
                                            ),
                                            TextFormField(
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: field3Controller,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      dateList[2].toString()),
                                            ),
                                            TextFormField(
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: field4Controller,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      dateList[3].toString()),
                                            ),
                                            TextFormField(
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: field5Controller,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      dateList[4].toString()),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    getDates();
                                                    for (var i = 0;
                                                        i < yieldList.length;
                                                        i++) {
                                                      debugPrint(yieldList[i]);
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      yieldList[0] =
                                                          field1Controller.text;
                                                      yieldList[1] =
                                                          field2Controller.text;
                                                      yieldList[2] =
                                                          field3Controller.text;
                                                      yieldList[3] =
                                                          field4Controller.text;
                                                      yieldList[4] =
                                                          field5Controller.text;
                                                    });
                                                    updateYields();

                                                    setState(() {
                                                      List<int> intList =
                                                          yieldList
                                                              .map((str) =>
                                                                  int.parse(
                                                                      str))
                                                              .toList();
                                                      maxNumber = intList
                                                          .reduce((currentMax,
                                                                  number) =>
                                                              currentMax >
                                                                      number
                                                                  ? currentMax
                                                                  : number);
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 60),
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 10),
                                height: 200,
                                width: 350,
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
                                  quantityPerClass: [
                                    double.parse(yieldList[0]),
                                    double.parse(yieldList[1]),
                                    double.parse(yieldList[2]),
                                    double.parse(yieldList[3]),
                                    double.parse(yieldList[4]),
                                  ],
                                ),
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
                      : recents.isNotEmpty
                          ? CarouselSlider.builder(
                              itemCount: recents.length,
                              options: CarouselOptions(
                                height: 250,
                                initialPage: (recents.length / 2).ceil(),
                                enlargeCenterPage: true,
                                viewportFraction: 1,
                              ),
                              itemBuilder: (context, index, realIndex) {
                                Timestamp t = recents[index]['date'];
                                DateTime d = t.toDate();
                                String date =
                                    DateFormat.yMMMd().add_jm().format(d);

                                return GestureDetector(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                            title: const Text(
                                              'Delete this entry?',
                                              textAlign: TextAlign.center,
                                            ),
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    QuerySnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        querySnapshot =
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'recents_identification')
                                                            .where('userId',
                                                                isEqualTo: recents[
                                                                        index]
                                                                    ['userId'])
                                                            .get();

                                                    if (querySnapshot
                                                        .docs.isNotEmpty) {
                                                      // Get the document reference and delete it
                                                      DocumentReference<
                                                              Map<String,
                                                                  dynamic>>
                                                          docRef = querySnapshot
                                                              .docs
                                                              .first
                                                              .reference;
                                                      docRef
                                                          .delete()
                                                          .then((value) {
                                                        setState(() {
                                                          recents
                                                              .removeAt(index);
                                                        });
                                                        print(
                                                            'Document successfully deleted!');
                                                      }).catchError((error) {
                                                        print(
                                                            'Error deleting document: $error');
                                                      });
                                                    } else {
                                                      print(
                                                          'No matching document found.');
                                                    }

                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: const Text('Yes'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('No'),
                                                ),
                                              ],
                                            ));
                                      },
                                    );
                                  },
                                  child: Recents(
                                    anthrachnose: recents[index]['anthracnose']
                                        .toString(),
                                    earlyBlight: recents[index]['earlyBlight']
                                        .toString(),
                                    leafSpot:
                                        recents[index]['leafSpot'].toString(),
                                    healthy:
                                        recents[index]['healthy'].toString(),
                                    date: date,
                                  ),
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
