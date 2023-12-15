import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/screeens/auth/signup/signup_form_widget.dart';
import 'package:leafcheck_project_v2/screeens/welcome_page/welcome_screen.dart';

import '../login/wave_clipper.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
                    color: Color.fromARGB(210, 99, 212, 167),
                  ),
                ),
              ),
              const Text(
                "Register",
                style: TextStyle(
                  color: Color(0xff2A6041),
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                "Create your account",
                style: TextStyle(
                  color: Color(0xff2A6041),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SignupFormWidget(),
            ],
          ),
        ));
  }
}
