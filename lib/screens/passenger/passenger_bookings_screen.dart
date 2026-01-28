import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PassengerBookingsScreen extends StatelessWidget {
  const PassengerBookingsScreen({super.key});

  Future<void> _cancelBooking(
    BuildContext context,
    DocumentReference bookingRef,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette demande ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await bookingRef.update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation annulée'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    final passengerId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('bookings')
            .where('passengerId', isEqualTo: passengerId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aucune réservation trouvée'),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final bookingDoc = bookings[index];
              final booking =
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

                  final trip =
                      tripSnapshot.data!.data() as Map<String, dynamic>;

                  final String status =
                      booking['status'] ?? 'pending';

                  Color statusColor;
                  String statusLabel;

                  switch (status) {
                    case 'accepted':
                      statusColor = Colors.green;
                      statusLabel = 'Acceptée';
                      break;
                    case 'rejected':
                      statusColor = Colors.red;
                      statusLabel = 'Refusée';
                      break;
                    case 'cancelled':
                      statusColor = Colors.grey;
                      statusLabel = 'Annulée';
                      break;
                    default:
                      statusColor = Colors.orange;
                      statusLabel = 'En attente';
                  }

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
                            '${trip['from']} → ${trip['to']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 6),
                          Text('📅 ${trip['date']} à ${trip['time']}'),
                          Text(
                            '💺 Places demandées : ${booking['seatsRequested'] ?? 1}',
                          ),
                          Text('💰 ${trip['price']} FCFA'),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      statusColor.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // ❌ Cancel button (ONLY if pending)
                              if (status == 'pending')
                                TextButton(
                                  onPressed: () => _cancelBooking(
                                    context,
                                    bookingDoc.reference,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Annuler'),
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
