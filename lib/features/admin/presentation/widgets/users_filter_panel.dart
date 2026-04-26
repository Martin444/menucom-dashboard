import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';

/// Panel de filtros para la vista de usuarios.
/// Extraído de UsersDesktopView._buildFilters para cumplir Atomic Design.
class UsersFilterPanel extends StatelessWidget {
  const UsersFilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

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
                  hintText: 'Buscar por nombre o email...',
                  onChanged: (_) {},
                  onSubmitted: controller.loadUsers,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(FluentIcons.add_24_regular),
                onPressed: controller.showCreateUserDialog,
                style: IconButton.styleFrom(
                  backgroundColor: PUColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChipAtom(
                    label: 'Todos',
                    selected: controller.selectedPlan.value.isEmpty,
                    onSelected: (_) => controller.filterByPlan(''),
                  ),
                  FilterChipAtom(
                    label: 'Free',
                    selected: controller.selectedPlan.value == 'free',
                    onSelected: (_) => controller.filterByPlan('free'),
                  ),
                  FilterChipAtom(
                    label: 'Premium',
                    selected: controller.selectedPlan.value == 'premium',
                    onSelected: (_) => controller.filterByPlan('premium'),
                  ),
                  FilterChipAtom(
                    label: 'Enterprise',
                    selected: controller.selectedPlan.value == 'enterprise',
                    onSelected: (_) => controller.filterByPlan('enterprise'),
                  ),
                ],
              )),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                children: [
                  FilterChipAtom(
                    label: 'Con membresía activa',
                    selected: controller.withActiveMembership.value,
                    onSelected: (_) => controller.toggleActiveMembership(),
                  ),
                  FilterChipAtom(
                    label: 'Con cuenta MP',
                    selected: controller.withVinculedAccount.value,
                    onSelected: (_) => controller.toggleVinculedAccount(),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
