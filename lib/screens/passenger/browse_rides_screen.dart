import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_details_screen.dart';

class BrowseRidesScreen extends StatelessWidget {
  const BrowseRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trajets disponibles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('status', isEqualTo: 'active')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ⏳ Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Erreur
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erreur lors du chargement des trajets',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 📭 Aucun trajet
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aucun trajet disponible pour le moment',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final trips = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final data = trip.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    '${data['from']} → ${data['to']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📅 ${data['date']} à ${data['time']}'),
                        const SizedBox(height: 4),
                        Text(
                          '💺 Places restantes : ${data['availableSeats']}',
                        ),
                      ],
                    ),
                  ),
                  trailing: Text(
                    '${data['price']} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF7C3AED), // Violet Covoicam
                    ),
                  ),
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TripDetailsScreen(
        tripId: trip.id,
        tripData: data,
      ),
    ),
  );
},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
