import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewImagesTaken extends StatefulWidget {
  const PreviewImagesTaken({
    super.key,
    required this.imageList,
  });

  final List<XFile> imageList;

  @override
  State<PreviewImagesTaken> createState() => _PreviewImagesTakenState();
}

class _PreviewImagesTakenState extends State<PreviewImagesTaken> {
  @override
  void dispose() {
    widget.imageList;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
        color: Color.fromARGB(179, 35, 151, 60),
      ),
      child: widget.imageList.isEmpty
          ? const Center(
              child: Text(
                "No image captured",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.imageList.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = widget.imageList.length - 1 - index;
                      return Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFF2A6041),
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(
                              widget.imageList[reversedIndex].path,
                            ),
                            filterQuality: FilterQuality.low,
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
