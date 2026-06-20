import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class CollaboratorRoleBadgeAtom extends StatelessWidget {
  final String role;
  final bool isActive;

  const CollaboratorRoleBadgeAtom({
    super.key,
    required this.role,
    this.isActive = true,
  });

  Color get _color {
    switch (role.toLowerCase()) {
      case 'owner':
        return const Color(0xFFF59E0B);
      case 'manager':
        return PUColors.primaryBlue;
      case 'staff':
      case 'operator':
        return const Color(0xFF10B981);
      default:
        return PUColors.textColorMuted;
    }
  }

  String get _label {
    switch (role.toLowerCase()) {
      case 'owner':
        return 'Dueño';
      case 'manager':
        return 'Manager';
      case 'staff':
      case 'operator':
        return 'Operador';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive ? _color : PUColors.textColorMuted;
    final effectiveBg = effectiveColor.withValues(alpha: 0.1);

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: ContainerAtom(
        variant: ContainerVariant.minimal,
        backgroundColor: effectiveBg,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          isActive ? _label : '$_label (inactivo)',
          style: TextStyle(
            color: effectiveColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
