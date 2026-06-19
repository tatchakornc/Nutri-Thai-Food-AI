// FILE: lib/firebase_options.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// FIREBASE CONFIGURATION PLACEHOLDER
// ─────────────────────────────────────────────────────────────────────────────
//
// Steps to generate the real file:
//
// 1. Install FlutterFire CLI:
//    dart pub global activate flutterfire_cli
//
// 2. Login to Firebase:
//    firebase login
//
// 3. Run FlutterFire configure inside this project folder:
//    flutterfire configure
//
//    This will:
//    - Create a Firebase project (or link an existing one)
//    - Register Android + iOS apps
//    - Download google-services.json + GoogleService-Info.plist automatically
//    - Overwrite this file with real API keys
//
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ─── REPLACE ALL VALUES BELOW WITH YOUR REAL FIREBASE CONFIG ──────────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIjwg1Ufsv0E7ZUdfh1Ug_jcs1_wR557A',
    appId: '1:151724763698:web:637cfeeb11442d3e266a2b',
    messagingSenderId: '151724763698',
    projectId: 'nutri-thai-food-ai-2026-05-02',
    authDomain: 'nutri-thai-food-ai-2026-05-02.firebaseapp.com',
    storageBucket: 'nutri-thai-food-ai-2026-05-02.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAoPfVvFId3jnHmJ_pxguKOKKPV-s8mc9o',
    appId: '1:151724763698:android:816c1e74a8d8fd7b266a2b',
    messagingSenderId: '151724763698',
    projectId: 'nutri-thai-food-ai-2026-05-02',
    storageBucket: 'nutri-thai-food-ai-2026-05-02.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCicT79pir6cwCc2pO-gWsjFZw0OB3DYxc',
    appId: '1:151724763698:ios:508d3d0ad89f4e01266a2b',
    messagingSenderId: '151724763698',
    projectId: 'nutri-thai-food-ai-2026-05-02',
    storageBucket: 'nutri-thai-food-ai-2026-05-02.firebasestorage.app',
    iosBundleId: 'com.example.nutriThaiFoodAi',
  );

}