import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/membership_admin_controller.dart';

/// Panel de KPIs de membresías.
/// Extraído de MembershipAdminDesktopView._buildKPIs para cumplir Atomic Design.
class MembershipKpiPanel extends StatelessWidget {
  const MembershipKpiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembershipAdminController>();

    return Obx(() {
      final stats = controller.stats;
      final totalPlans = stats['totalPlans'] ?? 0;
      final activePlans = stats['activePlans'] ?? 0;
      final customPlans = stats['customPlans'] ?? 0;
      final standardPlans = stats['standardPlans'] ?? 0;
      final archivedPlans = totalPlans - activePlans;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: 220,
            child: AdminKpiMolecule(
              title: 'Total Planes',
              value: '$totalPlans',
              icon: FluentIcons.premium_24_regular,
            ),
          ),
          SizedBox(
            width: 220,
            child: AdminKpiMolecule(
              title: 'Planes Activos',
              value: '$activePlans',
              icon: FluentIcons.checkmark_circle_24_regular,
              iconColor: Colors.green,
            ),
          ),
          SizedBox(
            width: 220,
            child: AdminKpiMolecule(
              title: 'Archivados',
              value: '$archivedPlans',
              icon: FluentIcons.archive_24_regular,
              iconColor: Colors.grey,
            ),
          ),
          SizedBox(
            width: 220,
            child: AdminKpiMolecule(
              title: 'Custom',
              value: '$customPlans',
              icon: FluentIcons.person_star_24_regular,
              iconColor: Colors.orange,
            ),
          ),
          SizedBox(
            width: 220,
            child: AdminKpiMolecule(
              title: 'Estándar',
              value: '$standardPlans',
              icon: FluentIcons.layer_24_regular,
              iconColor: Colors.blue,
            ),
          ),
        ],
      );
    });
  }
}
