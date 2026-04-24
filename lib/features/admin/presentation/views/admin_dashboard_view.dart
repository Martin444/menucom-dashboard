import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/views/users_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<DinningController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;

        if (isMobile) {
          return const AdminDashboardMobileView();
        }

        return const AdminDashboardDesktopView();
      },
    );
  }
}

class AdminDashboardMobileView extends StatelessWidget {
  const AdminDashboardMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Scaffold(
      drawer: const MenuSide(isMobile: true),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(FluentIcons.line_horizontal_3_24_regular),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() => AdminKpiMolecule(
                  title: 'Usuarios',
                  value: '${controller.dashboardData['totalUsers'] ?? 0}',
                  icon: FluentIcons.people_24_regular,
                )),
            const SizedBox(height: 16),
            Obx(() => AdminKpiMolecule(
                  title: 'Órdenes',
                  value: '${controller.dashboardData['totalOrders'] ?? 0}',
                  icon: FluentIcons.receipt_24_regular,
                )),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardDesktopView extends StatelessWidget {
  const AdminDashboardDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 250,
            child: MenuSide(isMobile: false),
          ),
          Expanded(
            child: Obx(() {
              final index = controller.selectedIndex.value;
              if (index == 0) {
                return _DashboardContent();
              }
              if (index == 1) {
                return const UsersDesktopView();
              }
              return _DashboardContent();
            }),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeaderMolecule(
            title: 'Admin Dashboard',
            onRefresh: controller.loadDashboardData,
          ),
          const SizedBox(height: 24),
          Obx(() => _KpiGrid(data: Map.from(controller.dashboardData))),
          const SizedBox(height: 32),
          Obx(() => _OrdersTable(orders: controller.recentOrders.toList())),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final Map<String, dynamic> data;

  const _KpiGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 240,
          child: AdminKpiMolecule(
            title: 'Usuarios',
            value: '${data['totalUsers'] ?? 0}',
            icon: FluentIcons.people_24_regular,
            onTap: () => Get.toNamed(PURoutes.ADMIN_USERS),
          ),
        ),
        SizedBox(
            width: 240,
            child: AdminKpiMolecule(
                title: 'Órdenes', value: '${data['totalOrders'] ?? 0}', icon: FluentIcons.receipt_24_regular)),
        SizedBox(
            width: 240,
            child: AdminKpiMolecule(
                title: 'Ingresos', value: '\$${data['revenue'] ?? 0}', icon: FluentIcons.money_24_regular)),
        SizedBox(
            width: 240,
            child: AdminKpiMolecule(
                title: 'Activos',
                value: '${data['activeSessions'] ?? 0}',
                icon: FluentIcons.checkmark_circle_24_regular)),
      ],
    );
  }
}

class _OrdersTable extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const _OrdersTable({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Órdenes Recientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          const Text('No hay órdenes recientes')
        else
          AdminDataTableMolecule(
            headers: const ['ID', 'Cliente', 'Estado', 'Total'],
            rows: orders
                .map((o) => AdminTableRow([
                      TextTableCell(o['id']?.toString() ?? ''),
                      TextTableCell(o['customer']?.toString() ?? ''),
                      BadgeTableCell(o['status']?.toString() ?? '', Colors.blue),
                      PriceTableCell((o['total'] as num?)?.toDouble() ?? 0),
                    ]))
                .toList(),
          ),
      ],
    );
  }
}
