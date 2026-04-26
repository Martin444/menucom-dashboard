import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';

/// Panel de KPIs de la vista de usuarios.
/// Extraído de UsersDesktopView._buildKPIs para cumplir Atomic Design.
class UsersKpiPanel extends StatelessWidget {
  const UsersKpiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Total Usuarios',
                value: '${controller.totalCount.value}',
                icon: FluentIcons.people_24_regular,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Con Membresía',
                value: '${controller.activeMembershipCount.value}',
                icon: FluentIcons.person_24_regular,
                iconColor: PUColors.primaryColor,
                iconBackground: PUColors.primaryBlueLight,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Cuentas MP',
                value: '${controller.vinculedCount.value}',
                icon: FluentIcons.wallet_24_regular,
                iconColor: PUColors.primaryBlue,
                iconBackground: PUColors.primaryBlueLight,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Verificados',
                value: '${controller.verifiedCount.value}',
                icon: FluentIcons.checkmark_circle_24_regular,
                iconColor: PUColors.ctaSuccess,
                iconBackground: PUColors.successColor,
              ),
            ),
          ],
        ));
  }
}
