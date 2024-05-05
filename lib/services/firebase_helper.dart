import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leafcheck_project_v2/models/user.dart';

class FirebaseHelper {
  FirebaseHelper._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> saveUser({
    required String email,
    required String password,
    required String name,
    // required String country,
    // required String region,
    // required String city,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        var userRef = FirebaseFirestore.instance.collection('users').doc(
              credential.user!.uid,
            );

        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          // country: country,
          // region: region,
          // city: city,
        );

        await userRef.set(userModel.toJson());

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }

    return null;
  }
}
