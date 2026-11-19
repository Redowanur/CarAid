import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'car_aid_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase powers auth + best-effort persistence. The demo journey works
  // offline too, so a failure here must never block the app from starting.
  try {
    await Firebase.initializeApp();
  } catch (error) {
    debugPrint('Firebase init skipped: $error');
  }

  runApp(const CarAidApp());
}
