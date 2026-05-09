import 'package:firebase_core/firebase_core.dart';
import '../core/config/firebase_options.dart';

Future<void> initializeFirebase() async {
  if (!DefaultFirebaseOptions.hasConfiguredApiKey) {
    await Firebase.initializeApp();
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
