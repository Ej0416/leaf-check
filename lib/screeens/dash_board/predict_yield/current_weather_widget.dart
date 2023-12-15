import 'package:flutter/material.dart';

class CurrentWEather extends StatelessWidget {
  CurrentWEather({
    super.key,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.widnSpeed,
    required this.cloudsall,
    required this.rain1h,
  });

  String temp,
      tempMin,
      tempMax,
      pressure,
      humidity,
      widnSpeed,
      cloudsall,
      rain1h;

  @override
  Widget build(BuildContext context) {
    double h = 80;
    double w = 80;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Temp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    temp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Temp Min',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    tempMin,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Temp Max',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    tempMax,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pressure',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    pressure,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Humidity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    humidity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Wind ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    widnSpeed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Clouds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    cloudsall,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: w,
              height: h,
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
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Rain',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    rain1h,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
