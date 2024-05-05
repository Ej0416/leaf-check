import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageListModel extends ChangeNotifier {
  List<XFile> images = [];

  addImage(XFile img) {
    images.add(img);
    notifyListeners();
  }

  listLength() {
    return images.length;
  }
}
