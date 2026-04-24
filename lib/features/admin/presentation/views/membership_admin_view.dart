import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/membership_admin_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';


class MembershipAdminView extends StatelessWidget {
  const MembershipAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;

        if (isMobile) {
          return const MembershipAdminMobileView();
        }

        return Scaffold(
          body: Row(
            children: [
              const SizedBox(
                width: 250,
                child: MenuSide(isMobile: false),
              ),
              const Expanded(child: MembershipAdminDesktopView()),
            ],
          ),
        );
      },
    );
  }
}

class MembershipAdminMobileView extends StatelessWidget {
  const MembershipAdminMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembershipAdminController>();

    return Scaffold(
      drawer: const MenuSide(isMobile: true),
      appBar: AppBar(
        title: const Text('Membresías'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(FluentIcons.line_horizontal_3_24_regular),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.add_24_regular),
            onPressed: controller.showCreatePlanDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.plans.isEmpty) {
          return const Center(
            child: Text('No hay planes de membresía'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadPlans,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.plans.length,
            itemBuilder: (context, index) {
              final plan = controller.plans[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(plan.name),
                  subtitle: Text('${plan.currency} ${plan.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(FluentIcons.edit_24_regular),
                        onPressed: () => controller.showEditPlanDialog(plan),
                      ),
                      IconButton(
                        icon: const Icon(FluentIcons.archive_24_regular),
                        onPressed: () => controller.confirmArchivePlan(plan),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class MembershipAdminDesktopView extends StatelessWidget {
  const MembershipAdminDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembershipAdminController>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminHeaderMolecule(
              title: 'Gestión de Membresías',
              onRefresh: () {
                controller.loadPlans();
                controller.loadStats();
              },
            ),
            const SizedBox(height: 24),
            _buildKPIs(controller),
            const SizedBox(height: 24),
            _buildPlansTable(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIs(MembershipAdminController controller) {
    return Obx(() {
      final totalPlans = controller.plans.length;
      final activePlans = controller.plans.where((p) => p.isActive).length;
      final archivedPlans = totalPlans - activePlans;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(
            width: 250,
            child: AdminKpiMolecule(
              title: 'Total Planes',
              value: '$totalPlans',
              icon: FluentIcons.premium_24_regular,
            ),
          ),
          SizedBox(
            width: 250,
            child: AdminKpiMolecule(
              title: 'Planes Activos',
              value: '$activePlans',
              icon: FluentIcons.checkmark_circle_24_regular,
              iconColor: Colors.green,
            ),
          ),
          SizedBox(
            width: 250,
            child: AdminKpiMolecule(
              title: 'Archivados',
              value: '$archivedPlans',
              icon: FluentIcons.archive_24_regular,
              iconColor: Colors.grey,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlansTable(MembershipAdminController controller) {
    return ContainerAtom(
      variant: ContainerVariant.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              headers: const ['Nombre', 'Precio', 'Estado', 'Acciones'],
              rows: controller.plans.map((plan) {
                return AdminTableRow([
                  TextTableCell(plan.name),
                  TextTableCell('${plan.currency} ${plan.price}'),
                  BadgeTableCell(
                    plan.isActive ? 'Activo' : 'Archivado',
                    plan.isActive ? Colors.green : Colors.grey,
                  ),
                  SwitchTableCell(
                    plan.isActive,
                    onChanged: (value) {
                      if (value == false) {
                        controller.confirmArchivePlan(plan);
                      }
                    },
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

