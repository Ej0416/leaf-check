import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/screeens/predict_image/results/result_page.dart';

class ConfirmIdentifyScreen extends StatefulWidget {
  const ConfirmIdentifyScreen({
    super.key,
    required this.imageList,
  });

  final List<XFile> imageList;

  @override
  State<ConfirmIdentifyScreen> createState() => _ConfirmIdentifyScreenState();
}

class _ConfirmIdentifyScreenState extends State<ConfirmIdentifyScreen> {
  late List<XFile> passedImageList = [];

  @override
  void initState() {
    passedImageList = List.from(widget.imageList);
    debugPrint("${widget.imageList.length}");
    super.initState();
  }

  @override
  void dispose() {
    widget.imageList;
    passedImageList;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade400,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Align(
          alignment: Alignment.topRight,
          child: Text("Confirm Images"),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 120,
            ),
            itemBuilder: (context, index) {
              final reversedIndex = passedImageList.length - 1 - index;
              if (index < passedImageList.length) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(passedImageList[reversedIndex].path),
                          filterQuality: FilterQuality.low,
                          fit: BoxFit.fill,
                          height: 120,
                          width: 140,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: 35,
                          width: 140,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(108, 0, 0, 0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 66, 66, 66),
                              ),
                              splashRadius: 20,
                              onPressed: () {
                                debugPrint("image at index $reversedIndex");
                                setState(() {
                                  passedImageList.removeAt(reversedIndex);
                                });
                              },
                              icon: const Icon(
                                Icons.cancel_outlined,
                                size: 25,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 150,
        child: FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff465362),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {
            debugPrint("${passedImageList.length}");
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) {
                return ResultPage(
                  imageList: passedImageList,
                );
              }),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.search_outlined),
              Text(
                "Identify".toUpperCase(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
