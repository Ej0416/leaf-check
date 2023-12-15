import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  TextEditingController emailCtrl = TextEditingController();

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailCtrl.text.trim(),
      );
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text(
                'Password Reset',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
              content: Text(
                'Passoword reset link set! Please Check your Email',
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          });
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Error',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              content: Text(
                e.message.toString(),
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.justify,
              ),
            );
          });
    }
  }

  @override
  void dispose() {
    emailCtrl;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Pass'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        // color: Colors.amber,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter Your Email and we will send a password reset link',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                labelText: "Email",
                hintText: "Your Email",
                prefixIcon: Icon(Icons.email_rounded),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: passwordReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
