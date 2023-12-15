import 'package:flutter/material.dart';

showCustomSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(148, 38, 38, 38),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 80,
      ),
      duration: const Duration(milliseconds: 1500),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber,
            color: Colors.amber,
          ),
          const SizedBox(width: 20),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          const Icon(
            Icons.warning_amber,
            color: Colors.amber,
          ),
        ],
      ),
    ),
  );
}
