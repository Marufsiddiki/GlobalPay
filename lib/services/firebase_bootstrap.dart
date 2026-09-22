import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } on FirebaseException {
      // Firebase options are supplied by the platform setup in production.
    }
  }
}