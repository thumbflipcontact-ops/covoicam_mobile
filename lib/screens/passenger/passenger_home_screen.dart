import 'package:flutter/material.dart';
import 'browse_rides_screen.dart';
import 'passenger_bookings_screen.dart';

class PassengerHomeScreen extends StatelessWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord passager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue 👋',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // 🔍 Browse available trips
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BrowseRidesScreen(),
                    ),
                  );
                },
                child: const Text('Rechercher un trajet'),
              ),
            ),

            const SizedBox(height: 16),

            // 📘 My bookings
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PassengerBookingsScreen(),
                    ),
                  );
                },
                child: const Text('Mes réservations'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
