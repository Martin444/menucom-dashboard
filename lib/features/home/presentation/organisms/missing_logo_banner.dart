import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

import '../../controllers/dinning_controller.dart';
import '../../../../routes/routes.dart';

class MissingLogoBanner extends GetView<DinningController> {
  const MissingLogoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasMissingLogo.value) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFB300).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              FluentIcons.warning_24_regular,
              color: Color(0xFFF57C00),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: PuTextStyle.description1.copyWith(
                    color: const Color(0xFF5D4037),
                  ),
                  children: [
                    const TextSpan(
                      text: 'Tu negocio aún no tiene logo configurado. ',
                    ),
                    TextSpan(
                      text: 'Configuralo desde el perfil del negocio para que tus clientes te reconozcan.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => Get.toNamed(PURoutes.BUSINESS_PROFILE),
              child: Text(
                'Ir al perfil',
                style: PuTextStyle.description1.copyWith(
                  color: PUColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
