import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    // El DinningController ya se inicializa en onInit con addPostFrameCallback
    // No llamar getMyDinningInfo() aquí

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
            child: _DashboardContent(),
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

    return RefreshIndicator(
      onRefresh: () async => controller.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminHeaderMolecule(
              title: 'Admin Dashboard',
              onRefresh: controller.loadDashboardData,
              searchHint: 'Buscar órdenes, usuarios...',
              onSearch: (query) => controller.search(query),
              actions: [
                _buildQuickAction(
                  icon: FluentIcons.person_add_24_regular,
                  tooltip: 'Agregar usuario',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  icon: FluentIcons.settings_24_regular,
                  tooltip: 'Configuración',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() => _KpiGrid(data: Map.from(controller.dashboardData))),
            const SizedBox(height: 32),
            Obx(() => _OrdersTable(orders: controller.recentOrders.toList())),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: ContainerAtom(
          variant: ContainerVariant.minimal,
          padding: const EdgeInsets.all(10),
          borderColor: PUColors.borderInputColor,
          borderWidth: 1,
          borderRadius: BorderRadius.circular(10),
          child: IconAtom(
            icon: icon,
            color: PUColors.textColorMuted,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final Map<String, dynamic> data;

  const _KpiGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            AdminKpiMolecule(
              title: 'Usuarios',
              value: '${data['totalUsers'] ?? 0}',
              icon: FluentIcons.people_24_regular,
              onTap: () => Get.toNamed(PURoutes.ADMIN_USERS),
            ),
            AdminKpiMolecule(
              title: 'Órdenes',
              value: '${data['totalOrders'] ?? 0}',
              icon: FluentIcons.receipt_24_regular,
              onTap: () {},
            ),
            AdminKpiMolecule(
              title: 'Ingresos',
              value: '\$${data['revenue'] ?? 0}',
              icon: FluentIcons.money_24_regular,
            ),
            AdminKpiMolecule(
              title: 'Activos',
              value: '${data['activeSessions'] ?? 0}',
              icon: FluentIcons.checkmark_circle_24_regular,
            ),
          ],
        );
      },
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
        Row(
          children: [
            const Text(
              'Órdenes Recientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(FluentIcons.arrow_right_24_regular, size: 16),
              label: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          ContainerAtom(
            variant: ContainerVariant.card,
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  IconAtom(
                    icon: FluentIcons.receipt_24_regular,
                    color: PUColors.textColorLight,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay órdenes recientes',
                    style: TextStyle(
                      color: PUColors.textColorMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          AdminDataTableMolecule(
            headers: const ['ID', 'Cliente', 'Estado', 'Total', 'Fecha'],
            rows: orders
                .map((o) => AdminTableRow([
                      TextTableCell(o['id']?.toString() ?? ''),
                      TextTableCell(o['customer']?.toString() ?? ''),
                      BadgeTableCell(
                        o['status']?.toString() ?? '',
                        _getStatusColor(o['status']?.toString() ?? ''),
                      ),
                      PriceTableCell((o['total'] as num?)?.toDouble() ?? 0),
                      TextTableCell(
                        o['date']?.toString() ?? '',
                        style: const TextStyle(color: PUColors.textColorMuted),
                      ),
                    ]))
                .toList(),
            showPagination: orders.length > 10,
            currentPage: 1,
            totalPages: (orders.length / 10).ceil(),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'completado':
        return Colors.green;
      case 'pending':
      case 'pendiente':
        return Colors.orange;
      case 'cancelled':
      case 'cancelado':
        return Colors.red;
      default:
        return PUColors.primaryBlue;
    }
  }
}
