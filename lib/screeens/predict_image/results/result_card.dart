import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/screeens/predict_image/results/more_info.dart';

import '../../../styles/font_styles.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.img,
    required this.predictionconf,
    required this.predictionCond,
    required this.fontStyles,
  });

  final XFile img;
  final String predictionconf;
  final String predictionCond;
  final CustomFontStyles fontStyles;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      elevation: 5,
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 10),
        leading: SizedBox(
          width: 90,
          child: Image.file(
            File(img.path),
            filterQuality: FilterQuality.low,
            fit: BoxFit.fill,
          ),
        ),
        title: Text(
          predictionCond.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        trailing: CircleAvatar(
          backgroundColor: const Color(0xff82a3a1),
          child: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return MoreInfo(
                  title: predictionCond,
                  img: img,
                  predictionconf: predictionconf,
                );
              }));
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
