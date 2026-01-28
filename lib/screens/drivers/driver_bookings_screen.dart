import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverBookingsScreen extends StatelessWidget {
  const DriverBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de réservation'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('bookings')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 📭 No pending bookings
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aucune demande en attente'),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final bookingDoc = bookings[index];
              final bookingData =
                  bookingDoc.data() as Map<String, dynamic>;

              final tripRef = bookingDoc.reference.parent.parent;
              if (tripRef == null) return const SizedBox.shrink();

              return FutureBuilder<DocumentSnapshot>(
                future: tripRef.get(),
                builder: (context, tripSnapshot) {
                  if (!tripSnapshot.hasData ||
                      !tripSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final tripData =
                      tripSnapshot.data!.data() as Map<String, dynamic>;

                  // 🔒 Only show bookings for this driver's trips
                  if (tripData['driverId'] != driverId) {
                    return const SizedBox.shrink();
                  }

                  final int availableSeats =
                      tripData['availableSeats'] ?? 0;
                  final int seatsRequested =
                      bookingData['seatsRequested'] ?? 1;

                  final bool canAccept =
                      availableSeats >= seatsRequested;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tripData['from']} → ${tripData['to']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '👤 Passager : ${bookingData['passengerName'] ?? 'Inconnu'}',
                          ),
                          Text(
                            '💺 Places demandées : $seatsRequested',
                          ),
                          Text(
                            '🚗 Places restantes : $availableSeats',
                          ),

                          const SizedBox(height: 10),

                          if (!canAccept)
                            const Text(
                              '🚫 Plus assez de places disponibles',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              // ✅ ACCEPT
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: !canAccept
                                      ? null
                                      : () async {
                                          try {
                                            await FirebaseFirestore.instance
                                                .runTransaction(
                                              (transaction) async {
                                                final tripSnap =
                                                    await transaction
                                                        .get(tripRef);
                                                final bookingSnap =
                                                    await transaction
                                                        .get(
                                                            bookingDoc.reference);

                                                if (!tripSnap.exists ||
                                                    !bookingSnap.exists) {
                                                  throw Exception(
                                                      'Données introuvables');
                                                }

                                                final trip =
                                                    tripSnap.data()
                                                        as Map<String, dynamic>;
                                                final booking =
                                                    bookingSnap.data()
                                                        as Map<String, dynamic>;

                                                final int currentSeats =
                                                    trip['availableSeats'] ?? 0;
                                                final int requestedSeats =
                                                    booking['seatsRequested'] ??
                                                        1;

                                                if (currentSeats <
                                                    requestedSeats) {
                                                  throw Exception(
                                                      'Plus assez de places');
                                                }

                                                // ✅ Accept booking
                                                transaction.update(
                                                  bookingSnap.reference,
                                                  {
                                                    'status': 'accepted',
                                                    'acceptedAt': FieldValue
                                                        .serverTimestamp(),
                                                  },
                                                );

                                                // 🔽 Reduce seats
                                                transaction.update(
                                                  tripRef,
                                                  {
                                                    'availableSeats':
                                                        currentSeats -
                                                            requestedSeats,
                                                  },
                                                );
                                              },
                                            );

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Réservation acceptée ✅'),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e.toString(),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  child: const Text('Accepter'),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // ❌ REJECT
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await bookingDoc.reference.update({
                                      'status': 'rejected',
                                      'rejectedAt':
                                          FieldValue.serverTimestamp(),
                                    });

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Réservation refusée ❌'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Refuser'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
