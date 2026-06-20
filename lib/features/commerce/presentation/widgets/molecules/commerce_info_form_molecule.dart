import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

class CommerceInfoFormMolecule extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController slugController;
  final TextEditingController descController;

  const CommerceInfoFormMolecule({
    super.key,
    required this.nameController,
    required this.slugController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del negocio',
          style: PuTextStyle.title3.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Los datos principales de tu comercio',
          style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        PUInput(
          controller: nameController,
          hintText: 'Ej: Mi Restaurante',
          labelText: 'Nombre del negocio',
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
        ),
        const SizedBox(height: 16),
        PUInput(
          controller: slugController,
          hintText: 'mi-restaurante',
          labelText: 'Slug (URL)',
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'El slug es obligatorio';
            if (!RegExp(r'^[a-z0-9-]+$').hasMatch(v.trim())) {
              return 'Solo letras minúsculas, números y guiones';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        PUInput(
          controller: descController,
          hintText: 'Describe brevemente tu negocio',
          labelText: 'Descripción',
          textInputType: TextInputType.multiline,
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}
