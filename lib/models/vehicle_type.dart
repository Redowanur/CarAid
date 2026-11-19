import 'package:flutter/material.dart';

enum UserRole { customer, mechanic }

extension UserRoleX on UserRole {
  String get label => this == UserRole.customer ? 'Customer' : 'Mechanic';
  String get firestoreValue => name;
}

class VehicleType {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;

  const VehicleType({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}
