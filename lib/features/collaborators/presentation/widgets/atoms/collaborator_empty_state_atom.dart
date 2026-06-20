import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class CollaboratorEmptyStateAtom extends StatelessWidget {
  final VoidCallback? onAdd;

  const CollaboratorEmptyStateAtom({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyStateAtom(
      title: 'Sin colaboradores',
      buttonText: onAdd != null ? 'Agregar colaborador' : null,
      onButtonPressed: onAdd,
    );
  }
}
