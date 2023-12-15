import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leafcheck_project_v2/screeens/dash_board/home/predict_yield_widget.dart';
import 'package:leafcheck_project_v2/screeens/dash_board/home/take_pick_widget.dart';
import 'package:leafcheck_project_v2/styles/font_styles.dart';

import '../../../services/firebase_helper.dart';
import 'recents.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? uid = FirebaseHelper.getCurrentUserId();

  CustomFontStyles fonts = CustomFontStyles();
  bool isSwap = false;

  List<Map<String, dynamic>> recents = [];
  List<Map<String, dynamic>> recentYield = [];

  Future getRecents() async {
    try {
      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('recents_identification')
          .where('userId', isEqualTo: uid)
          .get();

      QuerySnapshot qs2 = await FirebaseFirestore.instance
          .collection('recent_yield_prediction')
          .where('userId', isEqualTo: uid)
          .get();

      for (QueryDocumentSnapshot doc in qs.docs) {
        setState(() {
          recents.add(doc.data() as Map<String, dynamic>);
        });
      }

      for (QueryDocumentSnapshot doc2 in qs2.docs) {
        setState(() {
          recentYield.add(doc2.data() as Map<String, dynamic>);
        });
      }
    } catch (e) {
      debugPrint('Erro fetfching documents: $e');
    }
    // return recents;
  }

  @override
  void initState() {
    getRecents();
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
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                isSwap ? const PredictYieldWidget() : const TakePickWidget(),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    debugPrint(recents.toString());
                  },
                  child: Text(
                    "Recent",
                    style: fonts.titleFont,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              isSwap
                  ? recentYield.isNotEmpty
                      ? CarouselSlider.builder(
                          itemCount: recentYield.length,
                          options: CarouselOptions(
                            height: 250,
                            enableInfiniteScroll: false,
                            initialPage: (recents.length / 2).ceil(),
                            enlargeCenterPage: true,
                            viewportFraction: 1,
                          ),
                          itemBuilder: (context, index, realIndex) {
                            Timestamp t = recentYield[index]['date'];
                            DateTime d = t.toDate();
                            String date = DateFormat.yMMMd().add_jm().format(d);
                            return Column(
                              children: [
                                Text(
                                  'Predicted Yield | $date',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: 350,
                                  height: 175,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade400,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF000000),
                                        offset: Offset(-1, 4),
                                        blurRadius: 10,
                                        spreadRadius: -7,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text(
                                          'Yield\n Prediction',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          ': ${recentYield[index]['yield'].toString()} kg',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            String date = DateFormat.yMMMd().add_jm().format(d);

                            return Recents(
                              anthrachnose:
                                  recents[index]['anthracnose'].toString(),
                              earlyBlight:
                                  recents[index]['earlyBlight'].toString(),
                              leafSpot: recents[index]['leafSpot'].toString(),
                              healthy: recents[index]['healthy'].toString(),
                              date: date,
                            );
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }
}
