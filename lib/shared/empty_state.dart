import 'package:flutter/material.dart';
import 'primary_button.dart';
import '../app/strings.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onAction;

  const EmptyState({
    super.key,
    required this.message,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          PrimaryButton(
            text: AppStrings.seConnecter,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
