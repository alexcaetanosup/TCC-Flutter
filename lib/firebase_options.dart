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
    apiKey: 'AIzaSyD5hbLqj13iWQ5Woz5LTdpo5rb6z3U3npg',
    appId: '1:809080053823:web:d4d3d0a78288b4c627188a',
    messagingSenderId: '809080053823',
    projectId: 'cep-facil-4cad2',
    authDomain: 'cep-facil-4cad2.firebaseapp.com',
    storageBucket: 'cep-facil-4cad2.firebasestorage.app',
    measurementId: 'G-XSW9K58MXS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBN1yHXiF3Qr6UaK99xFPoc0okC7OANbm0',
    appId: '1:809080053823:android:80e8d830708b2c0d27188a',
    messagingSenderId: '809080053823',
    projectId: 'cep-facil-4cad2',
    storageBucket: 'cep-facil-4cad2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJcPFWUs_Bq0WZv4SxTxVi2MnIA-yhMKA',
    appId: '1:809080053823:ios:f4a1e9dc4110134027188a',
    messagingSenderId: '809080053823',
    projectId: 'cep-facil-4cad2',
    storageBucket: 'cep-facil-4cad2.firebasestorage.app',
    iosBundleId: 'com.example.cepFacil',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDJcPFWUs_Bq0WZv4SxTxVi2MnIA-yhMKA',
    appId: '1:809080053823:ios:f4a1e9dc4110134027188a',
    messagingSenderId: '809080053823',
    projectId: 'cep-facil-4cad2',
    storageBucket: 'cep-facil-4cad2.firebasestorage.app',
    iosBundleId: 'com.example.cepFacil',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD5hbLqj13iWQ5Woz5LTdpo5rb6z3U3npg',
    appId: '1:809080053823:web:7e2c2f74e8d5093227188a',
    messagingSenderId: '809080053823',
    projectId: 'cep-facil-4cad2',
    authDomain: 'cep-facil-4cad2.firebaseapp.com',
    storageBucket: 'cep-facil-4cad2.firebasestorage.app',
    measurementId: 'G-DBKQ9ZNQYP',
  );
}
