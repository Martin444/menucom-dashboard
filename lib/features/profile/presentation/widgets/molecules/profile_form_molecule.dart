import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

/// Profile Form Molecule - Molécula para formulario de edición de perfil
///
/// Contiene los campos de entrada para editar información del usuario
/// siguiendo los principios de atomic design.
class ProfileFormMolecule extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;

  const ProfileFormMolecule({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de nombre
          PUInput(
            controller: nameController,
            hintText: 'Ingresa tu nombre completo',
            labelText: 'Nombre',
            textInputType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: _validateName,
          ),

          const SizedBox(height: 20),

          // Campo de email
          PUInput(
            controller: emailController,
            hintText: 'Ingresa tu correo electrónico',
            labelText: 'Correo electrónico',
            textInputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),

          const SizedBox(height: 20),

          // Campo de teléfono
          PUInput(
            controller: phoneController,
            hintText: 'Ingresa tu número de teléfono',
            labelText: 'Teléfono',
            textInputType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: _validatePhone,
          ),
        ],
      ),
    );
  }

  /// Valida el nombre
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  /// Valida el email usando PUValidators
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    if (!PUValidators.validateEmail(value)) {
      return 'El formato del correo electrónico no es válido';
    }
    return null;
  }

  /// Valida el teléfono
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es obligatorio';
    }
    if (value.trim().length < 8) {
      return 'El teléfono debe tener al menos 8 dígitos';
    }
    return null;
  }
}
