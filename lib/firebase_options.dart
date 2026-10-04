// File generated for Firebase configuration
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAxQwWfP15ixdiYckHF1QuB6gfAYXmixoI',
    appId: '1:691642134346:web:ff35ea27b0c3eee8175bb3',
    messagingSenderId: '691642134346',
    projectId: 'omr-exam-f45b4',
    authDomain: 'omr-exam-f45b4.firebaseapp.com',
    storageBucket: 'omr-exam-f45b4.firebasestorage.app',
    measurementId: 'G-GX5F1MWXF6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxQwWfP15ixdiYckHF1QuB6gfAYXmixoI',
    appId: '1:691642134346:web:ff35ea27b0c3eee8175bb3',
    messagingSenderId: '691642134346',
    projectId: 'omr-exam-f45b4',
    storageBucket: 'omr-exam-f45b4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxQwWfP15ixdiYckHF1QuB6gfAYXmixoI',
    appId: '1:691642134346:web:ff35ea27b0c3eee8175bb3',
    messagingSenderId: '691642134346',
    projectId: 'omr-exam-f45b4',
    storageBucket: 'omr-exam-f45b4.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxQwWfP15ixdiYckHF1QuB6gfAYXmixoI',
    appId: '1:691642134346:web:ff35ea27b0c3eee8175bb3',
    messagingSenderId: '691642134346',
    projectId: 'omr-exam-f45b4',
    storageBucket: 'omr-exam-f45b4.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAxQwWfP15ixdiYckHF1QuB6gfAYXmixoI',
    appId: '1:691642134346:web:ff35ea27b0c3eee8175bb3',
    messagingSenderId: '691642134346',
    projectId: 'omr-exam-f45b4',
    storageBucket: 'omr-exam-f45b4.firebasestorage.app',
  );
}
