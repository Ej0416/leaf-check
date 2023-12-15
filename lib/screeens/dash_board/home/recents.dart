import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Recents extends StatelessWidget {
  Recents({
    super.key,
    required this.date,
    required this.anthrachnose,
    required this.earlyBlight,
    required this.leafSpot,
    required this.healthy,
  });

  String date;
  String anthrachnose;
  String earlyBlight;
  String leafSpot;
  String healthy;

  @override
  Widget build(BuildContext context) {
    int total = int.parse(anthrachnose) +
        int.parse(earlyBlight) +
        int.parse(leafSpot) +
        int.parse(healthy);

    return Column(
      children: [
        Text(
          'Identified Diseases | $date',
          style: const TextStyle(
            fontSize: 15,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 180,
          width: 350,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF000000),
                offset: Offset(-1, 4),
                blurRadius: 10,
                spreadRadius: -7,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                alignment: Alignment.center,
                // crossAxisAlignment: CrossAxisAlignment.end,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$total',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Total Plants',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            radius: 30,
                            value: double.parse(anthrachnose),
                            color: Colors.brown,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            radius: 30,
                            value: double.parse(earlyBlight),
                            color: Colors.blueGrey,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            radius: 30,
                            value: double.parse(leafSpot),
                            color: Colors.blue,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            radius: 30,
                            value: double.parse(healthy),
                            color: Colors.green.shade400,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  legends(Colors.brown, 'Anthracnose'),
                  legends(Colors.blueGrey, 'Early Blight'),
                  legends(Colors.blue, 'Leaf Spot'),
                  legends(Colors.green.shade400, 'Healthy'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container legends(Color color, String name) {
    return Container(
      padding: const EdgeInsets.all(6),
      width: 110,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Text(
        name,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  TextStyle style = const TextStyle(
    fontSize: 16,
    color: Colors.white,
    // fontWeight: FontWeight.w400,
  );
}
