import 'package:flutter/material.dart';

import '../auth/login/login_page.dart';
import '../auth/signup/signup_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        // padding: const EdgeInsets.symmetric(vertical: 100),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // logo
            Container(
              margin: const EdgeInsets.only(top: 40),
              height: 250,
              width: 250,
              child: const Image(
                image: AssetImage("assets/logos/leafcheck-logo-wc.png"),
                fit: BoxFit.fill,
              ),
            ),

            // button
            Column(
              children: [
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2A6041),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Navigator.of(context)
                      //     .push(MaterialPageRoute(builder: (BuildContext context) {
                      //   return const DashbardScreen();
                      // }));
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return LogInPage();
                      }));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Log-in",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.login_rounded)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(210, 99, 212, 167),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Navigator.of(context)
                      //     .push(MaterialPageRoute(builder: (BuildContext context) {
                      //   return const DashbardScreen();
                      // }));

                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return const SignUpPage();
                      }));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "Sign-up",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.person_add_alt_1)
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
