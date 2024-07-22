// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC7Lni3nVEvo7xj41SIq34zf8ievMb1Ps8',
    appId: '1:30747254339:android:19c1f2a3da6417f28b7ef6',
    messagingSenderId: '30747254339',
    projectId: 'leaf-check-storage',
    storageBucket: 'leaf-check-storage.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyClOub7JLvik8jpraAACts_wOAU3k2IvSs',
    appId: '1:30747254339:ios:1c0f4cd346dbde628b7ef6',
    messagingSenderId: '30747254339',
    projectId: 'leaf-check-storage',
    storageBucket: 'leaf-check-storage.appspot.com',
    iosClientId:
        '30747254339-gpf2927n9n5hplrcbikq3fpia7oukqup.apps.googleusercontent.com',
    iosBundleId: 'com.example.leafcheckProjectV2',
  );
}
