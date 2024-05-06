import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gtext/gtext.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simplytranslate/simplytranslate.dart';

class MoreInfo extends StatefulWidget {
  MoreInfo({
    super.key,
    required this.title,
    required this.img,
    required this.predictionconf,
  });

  String title;
  final XFile img;
  final String predictionconf;
  late String language = '';

  @override
  State<MoreInfo> createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
  final vt = SimplyTranslator(EngineType.libre);

  var db = FirebaseFirestore.instance;
  late String description = '';
  late List organic = [];
  late List chemical = [];
  late String classF = '';
  late bool notHeakthyOrInvalid = false;

  Future getDiseaseDesc(String disease) async {
    description = '';
    organic = [];
    chemical = [];

    final diseaseRef = db.collection('disease');
    final doc = await diseaseRef.where('name', isEqualTo: disease).get();
    final id = doc.docs.first.id;
    final DocumentSnapshot desc = await diseaseRef.doc(id).get();
    if (widget.title == 'Healthy') {
      setState(
        () {
          notHeakthyOrInvalid = true;
          description = desc['description'];
        },
      );
      debugPrint('healhty or invalid');
      debugPrint(notHeakthyOrInvalid.toString());
    } else if (widget.title == 'Unknown') {
      setState(
        () {
          notHeakthyOrInvalid = true;
          description = desc['description'];
        },
      );
      debugPrint('healhty or invalid');
      debugPrint(notHeakthyOrInvalid.toString());
    } else {
      setState(() {
        description = desc['description'];
        organic = desc['organic'];
        chemical = desc['chemical'];
        classF = desc['class'];
      });

      debugPrint(notHeakthyOrInvalid.toString());
    }
  }

  bool light = true;
  late String language = 'en';

  changeLang() {
    setState(() {
      if (language == 'en') {
        language = 'ceb';
      } else {
        language = 'en';
      }
    });
    getDiseaseDesc(widget.title);
    debugPrint('current languafe is: $language');
  }

  @override
  void initState() {
    getDiseaseDesc(widget.title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(90, 0, 0, 0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(68, 0, 0, 0),
        elevation: 0,
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                language == 'en' ? "English" : "Cebuano",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: light,
                activeColor: const Color.fromARGB(255, 44, 43, 43),
                onChanged: (bool value) {
                  setState(() {
                    light = value;
                    language = light ? 'en' : 'ceb';
                  });
                  debugPrint('current languafe is: $language');

                  // changeLang();
                  getDiseaseDesc(widget.title);
                },
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.green.shade400,
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: Image.file(
                File(widget.img.path),
                filterQuality: FilterQuality.medium,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              // height: MediaQuery.of(context).size.height * .6,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x00000000).withOpacity(1),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                    spreadRadius: -2,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x00000000).withOpacity(1),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                          spreadRadius: -2,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notHeakthyOrInvalid == false
                                    ? "Disease Identified"
                                    : widget.title == 'Healthy'
                                        ? 'Plant is healthy'
                                        : 'Disease Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                notHeakthyOrInvalid == false
                                    ? " We identified the disease on your Eggplant"
                                    : widget.title == 'Healthy'
                                        ? 'We identified that your Plant is healthy'
                                        : 'The disease is unknown',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // color: Colors.amber,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: notHeakthyOrInvalid == false
                                ? const Color(0xff465362)
                                : widget.title == 'Invalid'
                                    ? const Color(0xff465362)
                                    : const Color(0xff9fc490),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          classF,
                          style: TextStyle(
                            fontSize: notHeakthyOrInvalid == false ? 18 : 0,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xff465362),
                          ),
                        ),
                        const Divider(
                          thickness: 1.5,
                        ),
                        notHeakthyOrInvalid == false
                            ? Column(
                                children: [
                                  content(description, 'In a Nutshell'),
                                  content(organic, 'Organic Control'),
                                  content(chemical, 'Chemical Control'),
                                ],
                              )
                            : Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Icon(
                                    widget.title == 'Healthy'
                                        ? Icons.health_and_safety_outlined
                                        : Icons.warning_amber_rounded,
                                    size: 70,
                                    color: widget.title == 'Healthy'
                                        ? const Color(0xff9fc490)
                                        : const Color.fromARGB(
                                            255, 200, 176, 57),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container content(dynamic content, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: MediaQuery.of(context).size.width,
      // color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 10),
          content is List
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < content.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 10),
                        child: GText(
                          "\u25cf ${content[i]}",
                          toLang: language,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                  ],
                )
              : GText(
                  content.toString(),
                  toLang: language,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
        ],
      ),
    );
  }
}
