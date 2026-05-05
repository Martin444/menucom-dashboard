import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pu_material/pu_material.dart';
import '../molecules/share_link_display.dart';

class ShareQRCard extends StatelessWidget {
  final String menuUrl;
  final VoidCallback onCopy;

  const ShareQRCard({
    super.key,
    required this.menuUrl,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerAtom(
      variant: ContainerVariant.spacious,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        children: [
          ContainerAtom(
            variant: ContainerVariant.compact,
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            child: QrImageView(
              data: menuUrl,
              version: QrVersions.auto,
              semanticsLabel: 'Código QR del menú',
              size: 200.0,
              backgroundColor: Colors.transparent,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                color: Color(0xFF0F172A),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ShareLinkDisplay(
            menuUrl: menuUrl,
            onCopy: onCopy,
          ),
        ],
      ),
    );
  }
}
