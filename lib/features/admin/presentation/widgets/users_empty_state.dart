import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

/// Estado vacío genérico para la vista de usuarios.
/// Extraído de la clase privada _EmptyState de UsersView.
class UsersEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const UsersEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconAtom(
            icon: icon,
            color: PUColors.textColorLight,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: PuTextStyle.bodyMedium.copyWith(
              color: PUColors.textColorMuted,
            ),
          ),
        ],
      ),
    );
  }
}
