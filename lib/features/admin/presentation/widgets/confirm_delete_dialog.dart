import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/dialog_header_atom.dart';

/// Diálogo de confirmación de eliminación de usuario.
/// Refactorizado: eliminado _buildHeader, reemplazado por DialogHeaderAtom.
class ConfirmDeleteDialog extends StatelessWidget {
  final String userName;
  final VoidCallback? onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.userName,
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
              title: 'Eliminar Usuario',
              subtitle: 'Confirmación de seguridad',
              icon: Icons.warning_amber_rounded,
              accentColor: PUColors.errorColor,
              showCloseButton: false,
            ),

            Padding(
              padding: PUSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta acción no se puede deshacer.',
                    style: PuTextStyle.bodyMedium.copyWith(
                      color: PUColors.textColorRich,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: PuTextStyle.bodySmall
                          .copyWith(color: PUColors.textColorLight),
                      children: [
                        const TextSpan(
                            text:
                                '¿Estás seguro de que deseas eliminar permanentemente al usuario '),
                        TextSpan(
                          text: userName,
                          style: const TextStyle(
                            color: PUColors.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: '?'),
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
                    title: 'Eliminar Usuario',
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