import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/membership_admin_controller.dart';

/// Tabla de planes de membresía con encabezado y acciones.
/// Extraído de MembershipAdminDesktopView._buildPlansTable para cumplir Atomic Design.
class MembershipPlansTable extends StatelessWidget {
  const MembershipPlansTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembershipAdminController>();

    return ContainerAtom(
      variant: ContainerVariant.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Planes Disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: controller.showCreatePlanDialog,
                icon: const Icon(FluentIcons.add_24_regular),
                label: const Text('Crear Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PUColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.plans.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No hay planes registrados')),
              );
            }

            return AdminDataTableMolecule(
              headers: const [
                'Nombre',
                'Precio',
                'Límites',
                'Estado',
                'Acciones'
              ],
              rows: controller.plans.map((plan) {
                return AdminTableRow([
                  TextTableCell(plan.displayName ?? plan.name),
                  TextTableCell('${plan.currency} ${plan.price}'),
                  TextTableCell(
                      'C: ${plan.limits.maxCatalogs} | I: ${plan.limits.maxCatalogItems} | L: ${plan.limits.maxLocations}'),
                  BadgeTableCell(
                    plan.isActive ? 'Activo' : 'Archivado',
                    plan.isActive ? Colors.green : Colors.grey,
                  ),
                  WidgetTableCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(FluentIcons.edit_24_regular,
                              size: 20),
                          onPressed: () =>
                              controller.showEditPlanDialog(plan),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(FluentIcons.delete_24_regular,
                              size: 20, color: Colors.red),
                          onPressed: () =>
                              controller.confirmArchivePlan(plan),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
