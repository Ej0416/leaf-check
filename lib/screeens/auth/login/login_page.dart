import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/screeens/auth/login/wave_clipper.dart';

import '../../welcome_page/welcome_screen.dart';
import 'login_form_widget.dart';

class LogInPage extends StatelessWidget {
  LogInPage({super.key});

  final _logInFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return const WelcomeScreen();
            }));
          },
          icon: const Icon(Icons.arrow_back),
          iconSize: 35,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xff2A6041),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome Back!",
              style: TextStyle(
                color: Color(0xff2A6041),
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              "Login to your account",
              style: TextStyle(
                color: Color(0xff2A6041),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            LoginFormWidget(logInFormKey: _logInFormKey),
          ],
        ),
      ),
    );
  }
}
