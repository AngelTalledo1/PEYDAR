// Archivo generado manualmente desde google-services.json
// Android config — iOS se agrega cuando se configure GoogleService-Info.plist

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    // iOS aún no configurado
    throw UnsupportedError(
      'Firebase no configurado para esta plataforma: $defaultTargetPlatform',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoA0C1dLBYHOa9_aNPXKdxIysVixUHSBc',
    appId: '1:465438701111:android:2921d97d0374a2df5931b2',
    messagingSenderId: '465438701111',
    projectId: 'peydar-app',
    storageBucket: 'peydar-app.firebasestorage.app',
  );
}
