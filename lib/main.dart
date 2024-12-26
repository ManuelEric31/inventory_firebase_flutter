import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inventory_firebase/firebase_options.dart';
import 'package:inventory_firebase/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      home: const OnboardingScreen(),
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
    ),
  );
}
