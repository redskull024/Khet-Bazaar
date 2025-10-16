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
        return macos;
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
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCyYmIB6IsstXQSxiyRQnV97-bofwUOGMc',
    appId: '1:935255341347:web:60dfffb1e2b114976c7496',
    messagingSenderId: '935255341347',
    projectId: 'khet-bazaar-a225f',
    authDomain: 'khet-bazaar-a225f.firebaseapp.com',
    storageBucket: 'khet-bazaar-a225f.firebasestorage.app',
    measurementId: 'G-HWSG0VV1Y6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoUGNtqbn0AAS0fXlU3NxCawHfnnvN_fA',
    appId: '1:935255341347:android:3880fdd5bb7fa8246c7496',
    messagingSenderId: '935255341347',
    projectId: 'khet-bazaar-a225f',
    storageBucket: 'khet-bazaar-a225f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTwk27drcF2N9uUOoA_cwmKOUgxfVVrZ8',
    appId: '1:935255341347:ios:de06c10e3a9004fb6c7496',
    messagingSenderId: '935255341347',
    projectId: 'khet-bazaar-a225f',
    storageBucket: 'khet-bazaar-a225f.firebasestorage.app',
    androidClientId: '935255341347-d3g6vaj2a5pgkjg6jaln50tbqc31q0uk.apps.googleusercontent.com',
    iosClientId: '935255341347-aa1dihdq1tseomkp84ihjecm21gj5jsa.apps.googleusercontent.com',
    iosBundleId: 'com.example.farmConnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDTwk27drcF2N9uUOoA_cwmKOUgxfVVrZ8',
    appId: '1:935255341347:ios:de06c10e3a9004fb6c7496',
    messagingSenderId: '935255341347',
    projectId: 'khet-bazaar-a225f',
    storageBucket: 'khet-bazaar-a225f.firebasestorage.app',
    androidClientId: '935255341347-d3g6vaj2a5pgkjg6jaln50tbqc31q0uk.apps.googleusercontent.com',
    iosClientId: '935255341347-aa1dihdq1tseomkp84ihjecm21gj5jsa.apps.googleusercontent.com',
    iosBundleId: 'com.example.farmConnect',
  );

}