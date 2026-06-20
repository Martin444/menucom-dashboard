import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/clients/getx/clients_controller.dart';

class ClientsFilterPanel extends StatelessWidget {
  const ClientsFilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return ContainerAtom(
      variant: ContainerVariant.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SearchBarAtom(
                  controller: controller.searchController,
                  hintText: 'Buscar clientes por nombre o email...',
                  onChanged: (_) {},
                  onSubmitted: controller.loadClients,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChipAtom(
                    label: 'Todos',
                    selected: controller.selectedRole.value.isEmpty,
                    onSelected: (_) => controller.filterByRole(''),
                  ),
                  FilterChipAtom(
                    label: 'Clientes',
                    selected: controller.selectedRole.value == 'customer',
                    onSelected: (_) => controller.filterByRole('customer'),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
