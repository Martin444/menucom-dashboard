import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import '../atoms/share_status_icon.dart';

class ShareHeader extends StatelessWidget {
  const ShareHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      gradientColors: const [
        PUColors.primaryBlueDark,
        PUColors.secundaryBackground,
      ],
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: Column(
        children: [
          const ShareStatusIcon(),
          const SizedBox(height: 24),
          const TitleAtom(
            text: '¡Menú Publicado!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          SubtitleAtom(
            text: 'Tu menú ya está disponible para tus clientes',
            textAlign: TextAlign.center,
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
