import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ToPDF extends StatefulWidget {
  const ToPDF({super.key});

  @override
  State<ToPDF> createState() => _ToPDFState();
}

class _ToPDFState extends State<ToPDF> {
  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    String formattedDate = DateFormat('MMMM d, y \'at\' h:mm a').format(date);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Request storage permission
            var status = await Permission.storage.status;
            debugPrint(status.toString());
            if (!status.isGranted) {
              status = await Permission.storage.request();
            }

            if (status.isGranted) {
              try {
                // Fetch documents from Firestore
                QuerySnapshot snapshot =
                    await FirebaseFirestore.instance.collection('users').get();
                //  .orderBy('date', descending: true)
                // Generate CSV
                List<List<dynamic>> rows = [
                  [
                    'Email',
                    'Name',
                    'UID',
                  ],
                  for (var doc in snapshot.docs)
                    [
                      doc['email'],
                      doc['name'],
                      doc['uid'],
                    ]
                ];

                String csv = const ListToCsvConverter().convert(rows);

                // Save CSV to file
                final directory = await getExternalStorageDirectory();
                if (directory != null) {
                  final path = "${directory.path}/document.csv";
                  final file = io.File(path); // Use io.File
                  await file.writeAsString(csv);
                  debugPrint(path);

                  // Notify the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('CSV generated successfully at $path')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not access storage directory')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to generate CSV: $e')),
                );
              }
            } else {
              // Permission denied
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage permission denied')),
              );
            }
          },
          child: const Text('Generate CSV'),
        ),
      ),
    );
  }
}
