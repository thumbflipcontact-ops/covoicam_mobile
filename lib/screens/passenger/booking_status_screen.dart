import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingStatusScreen extends StatelessWidget {
  final String tripId;
  final String bookingId;

  const BookingStatusScreen({
    super.key,
    required this.tripId,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    final bookingRef = FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('bookings')
        .doc(bookingId);

    final tripRef =
        FirebaseFirestore.instance.collection('trips').doc(tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statut de la réservation'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: bookingRef.snapshots(),
        builder: (context, bookingSnapshot) {
          if (bookingSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!bookingSnapshot.hasData ||
              !bookingSnapshot.data!.exists) {
            return const Center(
              child: Text('Réservation introuvable'),
            );
          }

          final booking =
              bookingSnapshot.data!.data() as Map<String, dynamic>;
          final status = booking['status'];

          return FutureBuilder<DocumentSnapshot>(
            future: tripRef.get(),
            builder: (context, tripSnapshot) {
              if (!tripSnapshot.hasData) {
                return const SizedBox.shrink();
              }

              final trip =
                  tripSnapshot.data!.data() as Map<String, dynamic>;

              Color statusColor;
              String statusText;
              IconData statusIcon;

              switch (status) {
                case 'accepted':
                  statusColor = Colors.green;
                  statusText = 'Réservation acceptée';
                  statusIcon = Icons.check_circle;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusText = 'Réservation refusée';
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusText = 'En attente de confirmation';
                  statusIcon = Icons.hourglass_top;
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🚗 Route
                    Text(
                      '${trip['from']} → ${trip['to']}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 📅 Date & time
                    Text('📅 ${trip['date']}'),
                    Text('⏰ ${trip['time']}'),

                    const SizedBox(height: 12),

                    // 💰 Price
                    Text(
                      '💰 ${trip['price']} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 📌 Status box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // 🔙 Back
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Retour'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
