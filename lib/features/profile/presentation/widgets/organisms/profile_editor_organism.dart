import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

import '../../../../../core/utils/responsive_utils.dart';
import '../atoms/avatar_editor_atom.dart';
import '../molecules/profile_form_molecule.dart';

/// Profile Editor Organism - Organismo para edición completa de perfil
///
/// Combina el editor de avatar y el formulario de datos del usuario
/// en una sola unidad funcional siguiendo atomic design.
class ProfileEditorOrganism extends StatelessWidget {
  final String? currentImageUrl;
  final Uint8List? selectedImageBytes;
  final VoidCallback onSelectImage;
  final VoidCallback? onRemoveImage;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;

  const ProfileEditorOrganism({
    super.key,
    this.currentImageUrl,
    this.selectedImageBytes,
    required this.onSelectImage,
    this.onRemoveImage,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = ResponsiveUtils.isWeb(context);

        if (isWeb) {
          return _buildWebLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  /// Layout para web (lado a lado)
  Widget _buildWebLayout() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección del avatar (lado izquierdo)
            Expanded(
              flex: 2,
              child: _buildAvatarContent(),
            ),

            const SizedBox(width: 48),

            // Sección del formulario (lado derecho)
            Expanded(
              flex: 3,
              child: _buildFormContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Layout para mobile (vertical)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sección del avatar
        _buildAvatarSection(),

        const SizedBox(height: 24),

        // Sección del formulario
        _buildFormSection(),
      ],
    );
  }

  /// Construye el contenido del avatar para layout web
  Widget _buildAvatarContent() {
    return Column(
      children: [
        Text(
          'Foto de perfil',
          style: PuTextStyle.title3.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Agrega una foto para personalizar tu perfil',
          style: PuTextStyle.description1.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AvatarEditorAtom(
          currentImageUrl: currentImageUrl,
          selectedImageBytes: selectedImageBytes,
          onSelectImage: onSelectImage,
          onRemoveImage: onRemoveImage,
          size: 140,
        ),
      ],
    );
  }

  /// Construye el contenido del formulario para layout web
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información personal',
          style: PuTextStyle.title3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Actualiza tus datos para mantener tu perfil al día',
          style: PuTextStyle.description1.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        ProfileFormMolecule(
          nameController: nameController,
          emailController: emailController,
          phoneController: phoneController,
          formKey: formKey,
        ),
      ],
    );
  }

  /// Construye la sección del avatar para mobile
  Widget _buildAvatarSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Foto de perfil',
              style: PuTextStyle.title3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Agrega una foto para personalizar tu perfil',
              style: PuTextStyle.description1.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: AvatarEditorAtom(
                currentImageUrl: currentImageUrl,
                selectedImageBytes: selectedImageBytes,
                onSelectImage: onSelectImage,
                onRemoveImage: onRemoveImage,
                size: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la sección del formulario para mobile
  Widget _buildFormSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información personal',
              style: PuTextStyle.title3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Actualiza tus datos para mantener tu perfil al día',
              style: PuTextStyle.description1.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ProfileFormMolecule(
              nameController: nameController,
              emailController: emailController,
              phoneController: phoneController,
              formKey: formKey,
            ),
          ],
        ),
      ),
    );
  }
}
