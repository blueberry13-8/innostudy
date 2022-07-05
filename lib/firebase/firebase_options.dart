// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDscSoyqtyT_DNbKk5MzwpMS98NQZULCQ8',
    appId: '1:31031967889:web:b68c1983093de4fde6bf30',
    messagingSenderId: '31031967889',
    projectId: 'innostudy-df50a',
    authDomain: 'innostudy-df50a.firebaseapp.com',
    storageBucket: 'innostudy-df50a.appspot.com',
    measurementId: 'G-TZL4NC8J0Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfmswpzsdWm5mjIft71o_E9PSeTqDo6FE',
    appId: '1:31031967889:android:71835a65747da6bee6bf30',
    messagingSenderId: '31031967889',
    projectId: 'innostudy-df50a',
    storageBucket: 'innostudy-df50a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrtRGKJCg120_9ZMmF6RpKbaeXZ8AX630',
    appId: '1:31031967889:ios:65ec2ff8104e0a2fe6bf30',
    messagingSenderId: '31031967889',
    projectId: 'innostudy-df50a',
    storageBucket: 'innostudy-df50a.appspot.com',
    iosClientId: '31031967889-17cdajvaheev1di1vu66jsnot1lpit47.apps.googleusercontent.com',
    iosBundleId: 'com.example.innostudy',
  );
}