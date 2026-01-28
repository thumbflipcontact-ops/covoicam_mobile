import 'package:flutter/material.dart';

enum UserRole { driver, passenger }

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<UserRole>(
          title: const Text('I am a Driver'),
          value: UserRole.driver,
          groupValue: selectedRole,
          onChanged: (value) => onChanged(value!),
        ),
        RadioListTile<UserRole>(
          title: const Text('I am a Passenger'),
          value: UserRole.passenger,
          groupValue: selectedRole,
          onChanged: (value) => onChanged(value!),
        ),
      ],
    );
  }
}
