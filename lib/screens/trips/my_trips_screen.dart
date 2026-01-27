import 'package:flutter/material.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Mes trajets',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
