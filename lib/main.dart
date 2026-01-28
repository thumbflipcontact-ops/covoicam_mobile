import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Auth / routing
import 'shared/require_login.dart';

// Home screens by role
import 'screens/drivers/driver_home_screen.dart';
import 'screens/passenger/passenger_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

      // 🎨 YOUR THEME — UNCHANGED
      theme: ThemeData(
        primaryColor: const Color(0xFF7C3AED),
        scaffoldBackgroundColor: const Color(0xFFF9F5FF),
        useMaterial3: true,
      ),

      // 🔐 Auth gate + role routing
      home: const RequireLogin(
        driverChild: DriverHomeScreen(),
        passengerChild: PassengerHomeScreen(),
      ),
    );
  }
}
