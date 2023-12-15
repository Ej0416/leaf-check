import 'package:flutter/material.dart';

import '../../predict_image/take_images/take_pic_screen.dart';

class TakePickWidget extends StatelessWidget {
  const TakePickWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double h = 45;
    double w = 45;
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 20, top: 5),

      width: double.infinity,
      // height: 250,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: h,
                    height: w,
                    child: const Image(
                      image: AssetImage("assets/home/1.png"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Take a\n Picture",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded),
              Column(
                children: [
                  SizedBox(
                    width: h,
                    height: w,
                    child: const Image(
                      image: AssetImage("assets/home/2.png"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Get the\n Result",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded),
              Column(
                children: [
                  SizedBox(
                    width: h,
                    height: w,
                    child: const Image(
                      image: AssetImage("assets/home/3.png"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Get the \n Diagnostics",
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
                  return const TakePicScreen();
                }));
              },
              child: const Text(
                "Take a Picture",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
