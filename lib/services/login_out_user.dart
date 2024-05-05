import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/screeens/welcome_page/welcome_screen.dart';

import '../screeens/dash_board/dashboard_screen.dart';

// Future loginUser(BuildContext context, String email, String password) async {
//   try {
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Prevents dismissing the dialog when tapped outside
//       builder: (BuildContext context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );

//     UserCredential userCredential =
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (BuildContext context) {
//       return const DashbardScreen();
//     }));
//   } catch (e) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Login Failed'),
//           content: const Text('Invalid email or password. Please try again.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

Future<void> loginUser(
    BuildContext context, String email, String password) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Dismiss the progress dialog before navigating to the dashboard
    Navigator.of(context).pop();

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return const DashbardScreen();
    }));
  } catch (e) {
    // Dismiss the progress dialog before showing the login failed dialog
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid email or password. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Future logoutUser(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return const WelcomeScreen();
    }));
  } catch (e) {
    return false;
  }
}
