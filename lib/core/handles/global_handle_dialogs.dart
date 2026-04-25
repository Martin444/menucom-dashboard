import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/widgets/dialogs/plan_limit_dialog.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class GlobalDialogsHandles {
  static void snackbarError({
    required String title,
    String? message,
  }) {
    // Validar que el mensaje no esté vacío
    final String validMessage =
        message?.trim().isNotEmpty == true ? message!.trim() : 'Ha ocurrido un error inesperado';

    Get.snackbar(
      title,
      validMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: PUColors.bgError,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void snackbarSuccess({
    required String title,
    String? message,
  }) {
    // Validar que el mensaje no esté vacío
    final String validMessage =
        message?.trim().isNotEmpty == true ? message!.trim() : 'Operación completada exitosamente';

    Get.snackbar(
      title,
      validMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: PUColors.bgSuccess,
      colorText: Colors.white,
      margin: const EdgeInsets.all(20),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Future<bool> dialogConfirm({
    required String title,
    String? message,
  }) {
    var whenComplet = Completer<bool>();
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 300,
              maxWidth: 400,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: PuTextStyle.title1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  message ?? '',
                  textAlign: TextAlign.center,
                  style: PuTextStyle.title3,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        whenComplet.complete(false);
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        whenComplet.complete(true);
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

    return whenComplet.future;
  }

  /// Muestra un diálogo especializado para limitaciones del plan
  static void showPlanLimitDialog({
    required String title,
    required String message,
    VoidCallback? onUpgradePressed,
  }) {
    Get.dialog(
      PlanLimitDialog(
        title: title,
        message: message,
        onUpgradePressed: onUpgradePressed,
      ),
      barrierDismissible: true,
    );
  }
}
