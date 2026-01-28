import 'package:flutter/material.dart';
import 'create_ride_screen.dart';
import 'driver_bookings_screen.dart';
import 'driver_trips_screen.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace conducteur'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue conducteur 🚗\n\n'
              'Créez et gérez vos trajets,\n'
              'et répondez aux demandes des passagers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            // 📥 Booking requests
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.inbox),
                label: const Text('Demandes de réservation'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverBookingsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 🚗 My trips
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.directions_car),
                label: const Text('Mes trajets'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverTripsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ➕ Create Ride (PRIMARY ACTION)
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Créer un trajet'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateRideScreen(),
            ),
          );
        },
      ),
    );
  }
}
