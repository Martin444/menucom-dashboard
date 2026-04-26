import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/membership_admin_controller.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/membership_kpi_panel.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/membership_plans_table.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';

class MembershipAdminView extends StatelessWidget {
  const MembershipAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

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
                  title: Text(plan.displayName ?? plan.name),
                  subtitle: Text('${plan.currency} ${plan.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(FluentIcons.edit_24_regular),
                        onPressed: () =>
                            controller.showEditPlanDialog(plan),
                      ),
                      IconButton(
                        icon: const Icon(FluentIcons.delete_24_regular),
                        onPressed: () =>
                            controller.confirmArchivePlan(plan),
                        color: Colors.red,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminHeaderMolecule(
              title: 'Gestión de Membresías',
              onRefresh: () {
                controller.loadPlans();
                controller.loadStats();
              },
            ),
            const SizedBox(height: 24),
            const MembershipKpiPanel(),
            const SizedBox(height: 24),
            const MembershipPlansTable(),
          ],
        ),
      ),
    );
  }
}
