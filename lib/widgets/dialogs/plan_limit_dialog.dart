import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';

/// Widget de diálogo especializado para mostrar limitaciones del plan
/// 
/// Se usa cuando el usuario alcanza los límites de su plan gratuito
/// y necesita considerar actualizar a un plan superior.
class PlanLimitDialog extends StatelessWidget {
  const PlanLimitDialog({
    super.key,
    required this.title,
    required this.message,
    this.onUpgradePressed,
  });

  /// Título del diálogo
  final String title;
  
  /// Mensaje explicativo sobre la limitación
  final String message;
  
  /// Callback cuando el usuario presiona "Actualizar Plan"
  final VoidCallback? onUpgradePressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 450,
          maxHeight: 350,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de advertencia
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PUColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                color: PUColors.primaryColor,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Título
            Text(
              title,
              style: PuTextStyle.title1,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Mensaje
            Text(
              message,
              style: PuTextStyle.title3.copyWith(
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: PUColors.borderInputColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Entendido',
                      style: PuTextStyle.title3.copyWith(
                        color: PUColors.textColor1,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Botón Actualizar Plan
                Expanded(
                  child: ButtonPrimary(
                    title: 'Actualizar Plan',
                    load: false,
                    onPressed: () {
                      Get.back();
                      onUpgradePressed?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
