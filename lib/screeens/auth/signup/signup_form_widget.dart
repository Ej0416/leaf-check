import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leafcheck_project_v2/widgets/custom_snackbar_widget.dart';

import '../../../services/firebase_helper.dart';
import '../login/login_page.dart';

class SignupFormWidget extends StatefulWidget {
  const SignupFormWidget({
    super.key,
  });

  @override
  State<SignupFormWidget> createState() => _SignupFormWidgetState();
}

class _SignupFormWidgetState extends State<SignupFormWidget> {
  final userRef = FirebaseFirestore.instance.collection('users');
  final _signupFormKey = GlobalKey<FormState>();
  final TextEditingController signUpUserNameCtrl = TextEditingController();
  final TextEditingController signUpEmailCtrl = TextEditingController();
  final TextEditingController signUpPasswordCtrl = TextEditingController();
  final TextEditingController signUpConfirmPassCtrl = TextEditingController();

  bool isLoading = false;
  bool isTaken = false;

  @override
  void dispose() {
    signUpConfirmPassCtrl.dispose();
    signUpUserNameCtrl.dispose();
    signUpEmailCtrl.dispose();
    signUpPasswordCtrl.dispose();
    super.dispose();
  }

  Future isEmailExist() async {
    try {
      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(signUpEmailCtrl.text);

      if (signInMethods.isEmpty) {
        // Email doesn't exist, user can sign up
        debugPrint(
            '---------------------------------Email does not exist. User can sign up.');
        setState(() {
          isTaken = false;
        });
      } else {
        // Email exists, user cannot sign up with this email
        debugPrint(
            '---------------------------------Email already exists. User cannot sign up with this email.');
        isTaken = true;
      }
    } catch (e) {
      // Handle errors here
      debugPrint(
          '-----------------------------------Error checking email existence: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Container(
        height: 550,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                TextFormField(
                  controller: signUpUserNameCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelText: "Username",
                    hintText: "Enter Username",
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (username) {
                    if (username!.isEmpty) {
                      showCustomSnackBar(context, "Username is empty");
                      return "Username field is empty";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: signUpEmailCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelText: "E-mail",
                    hintText: "Enter your registered E-mail",
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (email) {
                    if (!EmailValidator.validate(email!)) {
                      showCustomSnackBar(context, "Invalid Email");
                      return "Email is invalid";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: signUpPasswordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (password) {
                    debugPrint("${password!.length}");
                    if (password.length < 8) {
                      showCustomSnackBar(
                          context, "Password must be 8 characters long");
                      return "Password must be 8 characters long";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: signUpConfirmPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelText: "Confirm Password",
                    hintText: "Confirm you password",
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (confirmPassword) {
                    if (confirmPassword != signUpPasswordCtrl.text) {
                      showCustomSnackBar(context,
                          "Password and Confirm Passwod \ndoes not match");
                      return "Passwords does`nt match";
                    }
                    return null;
                  },
                ),
              ],
            ),
            const Text(
              "By signing you agree to our Term of use and privacy",
              style: TextStyle(
                color: Color.fromARGB(120, 62, 62, 61),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: isLoading
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 160,
                            vertical: 15,
                          ),
                          child: const CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                              isEmailExist();
                            });
                            if (isTaken == true) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AlertDialog(
                                      title: Text(
                                        'Email Taken',
                                        style: TextStyle(
                                          color: Colors.amber,
                                        ),
                                      ),
                                      content: Text(
                                        'Email Already Taken',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  });
                              setState(() {
                                isLoading = false;
                              });
                            } else if (!_signupFormKey.currentState!
                                .validate()) {
                              debugPrint("..................not goods");
                              setState(() {
                                isLoading = false;
                              });
                            } else {
                              try {
                                debugPrint("...................all goods");
                                final isSaved = await FirebaseHelper.saveUser(
                                  email: signUpEmailCtrl.text,
                                  password: signUpConfirmPassCtrl.text,
                                  name: signUpUserNameCtrl.text,
                                );

                                _signupFormKey.currentState!.reset();
                                signUpUserNameCtrl.text = "";
                                signUpEmailCtrl.text = "";
                                signUpPasswordCtrl.text = "";
                                signUpConfirmPassCtrl.text = "";

                                debugPrint(isSaved.toString());

                                if (isTaken == true) {
                                  // ignore: use_build_context_synchronously
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AlertDialog(
                                          title: Text(
                                            'Email Already Taken',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                          content: Text(
                                            'Please choose anoher email as this email is already being use by another user.',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      });
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  setState(() {
                                    isLoading = false;
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) {
                                      return LogInPage();
                                    }));
                                  });
                                }
                              } catch (e) {
                                showCustomSnackBar(context, e.toString());
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(210, 99, 212, 167),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Register",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ),
                Container(
                  // margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return LogInPage();
                          }));
                        },
                        child: const Text("Log-in"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
