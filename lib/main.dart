import 'navigation/main_scaffold.dart';
import 'shared/require_login.dart';
import 'screens/home/home_screen.dart';
import 'auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely for supported platforms
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covoicam',

      // 🎨 YOUR EXISTING THEME — UNCHANGED
      theme: ThemeData(
        primaryColor: const Color(0xFF7C3AED), // Covoicam purple
        scaffoldBackgroundColor: const Color(0xFFF9F5FF),
        useMaterial3: true,
      ),

      home: const RequireLogin(
        child: MainScaffold(),
      ),
    );
  }
}
