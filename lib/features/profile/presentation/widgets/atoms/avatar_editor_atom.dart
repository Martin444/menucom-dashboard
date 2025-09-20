import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

/// Avatar Editor Atom - Átomo para editar avatar de usuario
///
/// Permite mostrar y cambiar la imagen de perfil del usuario
/// con funcionalidad de selección y eliminación de imagen.
class AvatarEditorAtom extends StatelessWidget {
  final String? currentImageUrl;
  final Uint8List? selectedImageBytes;
  final VoidCallback onSelectImage;
  final VoidCallback? onRemoveImage;
  final double size;

  const AvatarEditorAtom({
    super.key,
    this.currentImageUrl,
    this.selectedImageBytes,
    required this.onSelectImage,
    this.onRemoveImage,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar container
        Stack(
          alignment: Alignment.center,
          children: [
            // Imagen de avatar
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: PUColors.primaryColor.withOpacity(0.2),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarImage(),
              ),
            ),

            // Botón de cámara superpuesto
            Positioned(
              bottom: 0,
              right: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onSelectImage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PUColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      FluentIcons.camera_24_regular,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAvatarImage() {
    if (selectedImageBytes != null) {
      // Mostrar imagen seleccionada
      return Image.memory(
        selectedImageBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (currentImageUrl?.isNotEmpty == true) {
      // Mostrar imagen actual del usuario
      return PuRobustNetworkImage(
        imageUrl: currentImageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else {
      // Mostrar placeholder
      return Container(
        width: size,
        height: size,
        color: PUColors.bgInput,
        child: Icon(
          FluentIcons.person_24_regular,
          size: size * 0.4,
          color: PUColors.iconColor,
        ),
      );
    }
  }
}
