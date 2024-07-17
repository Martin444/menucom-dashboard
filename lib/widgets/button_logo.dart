import 'package:flutter/material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:svg_flutter/svg_flutter.dart';

class LogoButton extends StatelessWidget {
  final String? pathIcon;
  final Color? colorBackground;
  final void Function()? onTap;
  const LogoButton({
    super.key,
    this.pathIcon,
    this.colorBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: colorBackground,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            pathIcon ?? PUIcons.iconCart,
          ),
        ),
      ),
    );
  }
}
