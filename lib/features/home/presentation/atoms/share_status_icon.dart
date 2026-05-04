import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

class ShareStatusIcon extends StatelessWidget {
  const ShareStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      width: 80,
      height: 80,
      gradientColors: const [
        PUColors.primaryBlue,
        PUColors.primaryBlueDark,
      ],
      borderRadius: BorderRadius.circular(24),
      child: const Center(
        child: IconAtom(
          icon: FluentIcons.share_24_filled,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
