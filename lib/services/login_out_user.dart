
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/screeens/welcome_page/welcome_screen.dart';

import '../screeens/dash_board/dashboard_screen.dart';

Future loginUser(BuildContext context, String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return const DashbardScreen();
    }));
  } catch (e) {
    return false;
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
