import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class LogoButton extends StatelessWidget {
  final IconData? icon;
  final Color? colorBackground;
  final Color? iconColor;
  final double? iconSize;
  final void Function()? onTap;

  const LogoButton({
    super.key,
    this.icon,
    this.colorBackground,
    this.iconColor,
    this.iconSize,
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
          child: Icon(
            icon ?? FluentIcons.shopping_bag_24_regular,
            color: iconColor,
            size: iconSize ?? 24,
          ),
        ),
      ),
    );
  }
}
