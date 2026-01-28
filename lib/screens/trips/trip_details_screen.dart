import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_status_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> tripData;

  const TripDetailsScreen({
    super.key,
    required this.tripId,
    required this.tripData,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  bool isLoading = false;
  bool alreadyBooked = false;
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkExistingBooking();
  }

  Future<void> _checkExistingBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .collection('bookings')
        .where('passengerId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (!mounted) return;

    setState(() {
      alreadyBooked = snapshot.docs.isNotEmpty;
      isChecking = false;
    });
  }

  Future<void> _requestSeat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final bookingRef = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .collection('bookings')
          .add({
        'passengerId': user.uid,
        'status': 'pending', // pending | accepted | rejected
        'seatsRequested': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // ➜ Go to booking status screen (D8)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingStatusScreen(
            tripId: widget.tripId,
            bookingId: bookingRef.id,
          ),
        ),
      );

      setState(() => alreadyBooked = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.tripData;

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

            // 📅 Date & Time
            Text('📅 Date : ${data['date']}'),
            Text('⏰ Heure : ${data['time']}'),

            const SizedBox(height: 8),

            // 💺 Seats
            Text('💺 Places disponibles : ${data['availableSeats']}'),

            const SizedBox(height: 8),

            // 💰 Price
            Text(
              '💰 Prix : ${data['price']} FCFA',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            // 🟣 Request button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (alreadyBooked || isLoading || isChecking)
                    ? null
                    : _requestSeat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: isChecking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : alreadyBooked
                        ? const Text(
                            'Demande déjà envoyée',
                            style: TextStyle(color: Colors.white),
                          )
                        : isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Demander une place',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
