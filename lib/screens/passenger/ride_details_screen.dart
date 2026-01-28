import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideDetailsScreen extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> tripData;

  const RideDetailsScreen({
    super.key,
    required this.tripId,
    required this.tripData,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  bool isLoading = false;
  int seatsRequested = 1;

  Future<void> requestSeat() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .collection('bookings')
        .add({
      'passengerId': user.uid,
      'passengerName': user.displayName ?? 'Passager',
      'seatsRequested': seatsRequested,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demande envoyée au conducteur 🚀'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.tripData;
    final int availableSeats = data['availableSeats'] ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚗 Route
            Text(
              '${data['from']} → ${data['to']}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text('📅 Date : ${data['date']}'),
            Text('⏰ Heure : ${data['time']}'),
            Text('💺 Places disponibles : $availableSeats'),
            Text('💰 Prix : ${data['price']} FCFA'),

            const SizedBox(height: 24),

            // 🎟 Seat selector
            const Text(
              'Nombre de places',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                IconButton(
                  onPressed: seatsRequested > 1
                      ? () => setState(() => seatsRequested--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  seatsRequested.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: seatsRequested < availableSeats
                      ? () => setState(() => seatsRequested++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const Spacer(),

            // 🟣 Request button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading || availableSeats == 0 ? null : requestSeat,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Demander une place'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
