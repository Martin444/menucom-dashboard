import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// Header reutilizable para diálogos admin.
/// Elimina la duplicación de `_buildHeader()` en UserDetailDialog,
/// EditUserDialog, AssignMembershipDialog y ConfirmDeleteDialog.
class DialogHeaderAtom extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final bool showCloseButton;

  const DialogHeaderAtom({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? PUColors.primaryBlue;

    return Container(
      padding: PUSpacing.lg,
      decoration: BoxDecoration(
        color: color == PUColors.errorColor
            ? PUColors.errorColor.withValues(alpha: 0.05)
            : PUColors.primaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: PUTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleAtom(text: title, level: TitleLevel.h3),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PUColors.textColorLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(FluentIcons.dismiss_24_regular),
              onPressed: () => Get.back(),
              color: PUColors.textColorLight,
            ),
        ],
      ),
    );
  }
}
