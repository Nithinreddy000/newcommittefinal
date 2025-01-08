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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.macOS:
        return windows;
      case TargetPlatform.linux:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAopioxqBbDbD3FmvZAB7Har-AL3AE7QA',
    appId: '1:138509251676:web:a6c86e873580b0d590a299',
    messagingSenderId: '138509251676',
    projectId: 'commitee-app',
    authDomain: 'commitee-app.firebaseapp.com',
    storageBucket: 'commitee-app.appspot.com',
    measurementId: 'G-3TSC478GQJ',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAopioxqBbDbD3FmvZAB7Har-AL3AE7QA',
    appId: '1:138509251676:web:a6c86e873580b0d590a299',
    messagingSenderId: '138509251676',
    projectId: 'commitee-app',
    authDomain: 'commitee-app.firebaseapp.com',
    storageBucket: 'commitee-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCXqUz99LIN3fFkmsmG8Ilgd6ZrBzscnw',
    appId: '1:138509251676:android:df6d2010e95154b490a299',
    messagingSenderId: '138509251676',
    projectId: 'commitee-app',
    storageBucket: 'commitee-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZTEs_pQz79TbMCzBkI7a5CKiAdzdtIVw',
    appId: '1:138509251676:ios:c67eeca0e6acfc8790a299',
    messagingSenderId: '138509251676',
    projectId: 'commitee-app',
    storageBucket: 'commitee-app.firebasestorage.app',
    iosClientId: 'committe123',
    iosBundleId: 'committe123',
  );
}