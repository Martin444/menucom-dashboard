import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/clients/getx/clients_controller.dart';

class ClientsKpiPanel extends StatelessWidget {
  const ClientsKpiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return Obx(() => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Total Clientes',
                value: '${controller.totalCount.value}',
                icon: FluentIcons.people_24_regular,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Activos',
                value: '${controller.activeClientsCount.value}',
                icon: FluentIcons.checkmark_circle_24_regular,
                iconColor: PUColors.primaryBlue,
                iconBackground: PUColors.primaryBlueLight,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Nuevos este mes',
                value: '${controller.newThisMonthCount.value}',
                icon: FluentIcons.person_add_24_regular,
                iconColor: PUColors.ctaSuccess,
                iconBackground: PUColors.successColor,
              ),
            ),
          ],
        ));
  }
}
