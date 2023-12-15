import 'package:flutter/material.dart';

import '../predict_yield/predict_yield_screen copy.dart';

class PredictYieldWidget extends StatelessWidget {
  const PredictYieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 20, top: 5),
      width: double.infinity,
      height: 190,
      decoration: const BoxDecoration(
        // color: Color(0xFF2CEAA3),
        color: Color.fromARGB(255, 255, 255, 255),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: const [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image(
                      image: AssetImage("assets/home/4.png"),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Press \n Button",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded),
              Column(
                children: const [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image(
                      image: AssetImage("assets/home/5.png"),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Get the\n Result",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor: const Color(0xff465362),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return const PredictYieldScreenCopy();
                }));
              },
              child: const Text(
                "Predict Yield",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
