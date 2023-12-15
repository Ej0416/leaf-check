import 'package:flutter/material.dart';

class CustomFontStyles {
  TextStyle titleFont = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  TextStyle weatherWidgetTitle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
  );

  TextStyle weatherTemperatur = const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: Color(0xFF2A6041),
  );

  TextStyle weatherDesc = const TextStyle(
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );

  TextStyle resultText = const TextStyle(
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w600,
    fontSize: 22,
  );
}
