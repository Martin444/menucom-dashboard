import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class GlobalDialogsHandles {
  static void snackbarError({
    required String title,
    String? message,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: PUColors.bgError,
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  static void snackbarSuccess({
    required String title,
    String? message,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: PUColors.bgSucces,
        duration: const Duration(
          seconds: 2,
        ),
      ),
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
}
