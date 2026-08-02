
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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
    apiKey: 'AIzaSyDSmGUs-P8Ini73aEzQBitc9reoaFwV-6I',
    appId: '1:398608890750:web:3cfbea740e46b4f3e5112f',
    messagingSenderId: '398608890750',
    projectId: 'spreemall',
    authDomain: 'spreemall.firebaseapp.com',
    storageBucket: 'spreemall.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNwesJKLq7MMDaf_BcY0MGTSLAWdgbSW8',
    appId: '1:398608890750:android:31cd2d1b8c952f27e5112f',
    messagingSenderId: '398608890750',
    projectId: 'spreemall',
    storageBucket: 'spreemall.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTF2jnmF6XAEu_sld1CflhC-vEz1KtRbw',
    appId: '1:398608890750:ios:f7030de5a1ee4831e5112f',
    messagingSenderId: '398608890750',
    projectId: 'spreemall',
    storageBucket: 'spreemall.firebasestorage.app',
    iosBundleId: 'com.example.spreemall',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDSmGUs-P8Ini73aEzQBitc9reoaFwV-6I',
    appId: '1:398608890750:web:081e75b774698122e5112f',
    messagingSenderId: '398608890750',
    projectId: 'spreemall',
    authDomain: 'spreemall.firebaseapp.com',
    storageBucket: 'spreemall.firebasestorage.app',
  );
}
