import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

class CommerceLogoPickerAtom extends StatelessWidget {
  final Uint8List? logoBytes;
  final VoidCallback onSelectImage;
  final bool isLoading;

  const CommerceLogoPickerAtom({
    super.key,
    this.logoBytes,
    required this.onSelectImage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Logo del negocio',
          style: PuTextStyle.title3.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Agrega un logo para identificar tu comercio',
          style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isLoading ? null : onSelectImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PUColors.bgInput,
                border: Border.all(
                  color: PUColors.primaryColor.withValues(alpha: 0.2),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (logoBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(logoBytes!, fit: BoxFit.cover),
          _buildHoverOverlay(),
          _buildCameraOverlay(),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Icon(
            FluentIcons.image_24_regular,
            size: 48,
            color: PUColors.iconColor,
          ),
        ),
        _buildCameraOverlay(),
      ],
    );
  }

  Widget _buildHoverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.0),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildCameraOverlay() {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: PUColors.primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          FluentIcons.camera_24_regular,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
