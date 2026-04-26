import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/dialog_header_atom.dart';

/// Diálogo de confirmación para archivar un plan de membresía.
/// Extraído de MembershipAdminController para cumplir separación vista/lógica.
/// Refactorizado: usa DialogHeaderAtom en lugar de header inline.
class ConfirmArchiveDialog extends StatelessWidget {
  final String planName;
  final VoidCallback? onConfirm;

  const ConfirmArchiveDialog({
    super.key,
    required this.planName,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: PUColors.glassShadow,
      shape: RoundedRectangleBorder(borderRadius: PUBorderRadius.xl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DialogHeaderAtom(
              title: 'Archivar Plan',
              subtitle: 'Confirmación de seguridad',
              icon: FluentIcons.archive_24_regular,
              accentColor: PUColors.errorColor,
              showCloseButton: false,
            ),

            Padding(
              padding: PUSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Estás seguro de que deseas archivar este plan?',
                    style: PuTextStyle.bodyMedium.copyWith(
                      color: PUColors.textColorRich,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: PuTextStyle.bodySmall.copyWith(
                          color: PUColors.textColorLight),
                      children: [
                        const TextSpan(text: 'El plan '),
                        TextSpan(
                          text: planName,
                          style: const TextStyle(
                            color: PUColors.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                            text:
                                ' dejará de estar disponible para nuevos usuarios.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: PUColors.borderInputColor),

            Padding(
              padding: PUSpacing.md,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonSecundary(
                    load: false,
                    title: 'Cancelar',
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: PUTokens.sm),
                  ButtonPrimary(
                    load: false,
                    title: 'Archivar',
                    onPressed: () {
                      Get.back();
                      onConfirm?.call();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
