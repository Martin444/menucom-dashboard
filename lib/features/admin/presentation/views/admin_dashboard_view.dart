import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart' hide Order, OrderItem;
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:menu_dart_api/by_feature/orders/models/order_model.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

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
      body: RefreshIndicator(
        onRefresh: () async => controller.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() => DashboardKpiGrid(data: Map.from(controller.dashboardData))),
              const SizedBox(height: 24),
              Obx(() => DashboardOrdersTable(orders: controller.ordersToDisplay)),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboardDesktopView extends StatelessWidget {
  const AdminDashboardDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 250,
            child: MenuSide(isMobile: false),
          ),
          const Expanded(
            child: DashboardContent(),
          ),
        ],
      ),
    );
  }
}

/// Contenido principal del dashboard administrativo.
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

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
                QuickActionButton(
                  icon: FluentIcons.person_add_24_regular,
                  tooltip: 'Agregar usuario',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                QuickActionButton(
                  icon: FluentIcons.settings_24_regular,
                  tooltip: 'Configuración',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() => DashboardKpiGrid(
                data: Map.from(controller.dashboardData))),
            const SizedBox(height: 32),
            Obx(() => DashboardOrdersTable(
                orders: controller.ordersToDisplay)),
          ],
        ),
      ),
    );
  }
}

/// Botón de acción rápida del header del dashboard.
/// Extraído de _DashboardContent._buildQuickAction para cumplir Atomic Design.
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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

/// Grid de KPIs del dashboard.
class DashboardKpiGrid extends StatelessWidget {
  final Map<String, dynamic> data;

  const DashboardKpiGrid({super.key, required this.data});

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
              value: '\$${(data['revenue'] as num? ?? 0).toStringAsFixed(2)}',
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

/// Tabla de órdenes recientes del dashboard.
class DashboardOrdersTable extends StatelessWidget {
  final List<Order> orders;

  const DashboardOrdersTable({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

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
              onPressed: () => Get.toNamed(PURoutes.ORDERS_PAGES),
              icon: const Icon(FluentIcons.arrow_right_24_regular, size: 16),
              label: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value && orders.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (orders.isEmpty) {
            return ContainerAtom(
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
            );
          }

          return Column(
            children: [
              AdminDataTableMolecule(
                headers: const ['ID', 'Cliente', 'Contacto', 'Estado', 'Items', 'Total', 'Fecha', 'Acciones'],
                rows: orders
                    .map((o) => AdminTableRow([
                          TextTableCell(
                            o.id != null ? '#${o.id!.substring(0, 8)}' : '---',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          WidgetTableCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${o.customerName ?? ''} ${o.customerLastName ?? ''}'.trim(),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                if (o.customerEmail != null)
                                  Text(
                                    o.customerEmail!,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          WidgetTableCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (o.customerPhone != null)
                                  Text(o.customerPhone!, style: const TextStyle(fontSize: 12)),
                                if (o.store?.businessName != null)
                                  Text(
                                    o.store!.businessName!,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          BadgeTableCell(
                            _mapStatus(o.status ?? 'pending'),
                            _getStatusColor(o.status ?? ''),
                          ),
                          WidgetTableCell(
                            Text(
                              '${o.items?.length ?? 0} artículos',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          PriceTableCell(o.total ?? 0),
                          TextTableCell(
                            o.createdAt != null
                                ? '${o.createdAt!.day.toString().padLeft(2, '0')}/${o.createdAt!.month.toString().padLeft(2, '0')}/${o.createdAt!.year}'
                                : '---',
                            style: const TextStyle(color: PUColors.textColorMuted, fontSize: 13),
                          ),
                          WidgetTableCell(
                            IconButton(
                              icon: const Icon(FluentIcons.eye_24_regular, size: 20, color: PUColors.primaryBlue),
                              onPressed: () => _showOrderDetailDialog(o),
                              tooltip: 'Ver detalle',
                              splashRadius: 20,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ]))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: controller.currentPage.value > 1
                        ? () => controller.changePage(controller.currentPage.value - 1)
                        : null,
                    icon: const Icon(FluentIcons.chevron_left_24_regular),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Página ${controller.currentPage.value}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: controller.hasMore.value
                        ? () => controller.changePage(controller.currentPage.value + 1)
                        : null,
                    icon: const Icon(FluentIcons.chevron_right_24_regular),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  String _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'created':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'processing':
      case 'in_progress':
        return 'En curso';
      case 'completed':
      case 'finished':
        return 'Completado';
      case 'cancelled':
      case 'canceled':
        return 'Cancelado';
      case 'failed':
        return 'Fallido';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'completado':
      case 'finished':
      case 'success':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
      case 'in_progress':
      case 'en curso':
        return Colors.orange;
      case 'pending':
      case 'pendiente':
      case 'created':
        return Colors.amber;
      case 'cancelled':
      case 'cancelado':
      case 'canceled':
      case 'failed':
      case 'fallido':
        return Colors.red;
      default:
        return PUColors.primaryBlue;
    }
  }

  void _showOrderDetailDialog(Order order) {
    final paymentStatusColor = switch (order.paymentStatus?.toLowerCase()) {
      'approved' => Colors.green,
      'rejected' || 'refunded' => Colors.red,
      'pending' => Colors.orange,
      _ => Colors.grey,
    };
    final paymentStatusIcon = switch (order.paymentStatus?.toLowerCase()) {
      'approved' => FluentIcons.checkmark_circle_24_filled,
      'rejected' || 'refunded' => FluentIcons.error_circle_24_regular,
      'pending' => FluentIcons.hourglass_24_regular,
      _ => FluentIcons.question_24_regular,
    };

    final customerName = '${order.customerName ?? ''} ${order.customerLastName ?? ''}'.trim();

    Get.dialog(
      AlertDialog(
        title: Text('Detalle de Orden #${order.id?.substring(0, 8) ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customerName.isNotEmpty)
                Text('Cliente: $customerName', style: const TextStyle(fontWeight: FontWeight.w500)),
              if (order.customerEmail != null)
                Text(order.customerEmail!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (order.customerPhone != null)
                Text('Tel: ${order.customerPhone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusBadge(_mapStatus(order.status ?? 'pending')),
                  const SizedBox(width: 8),
                  if (order.paymentStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: paymentStatusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: paymentStatusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(paymentStatusIcon, size: 14, color: paymentStatusColor),
                          const SizedBox(width: 4),
                          Text(
                            _mapPaymentStatusToLabel(order.paymentStatus!),
                            style: TextStyle(fontSize: 11, color: paymentStatusColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.store != null) ...[
                Row(
                  children: [
                    const Icon(FluentIcons.store_microsoft_24_regular, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tienda: ${order.store!.businessName ?? '---'}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                if (order.store!.businessPhone != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      'Tel tienda: ${order.store!.businessPhone}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
              const Divider(),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...?order.items?.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.quantity}x ${item.productName}'),
                    ),
                    const SizedBox(width: 16),
                    Text('\$${item.price.toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('\$${(order.subtotal ?? 0).toStringAsFixed(2)}'),
                ],
              ),
              if ((order.marketplaceFeeAmount ?? 0) > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comisión Menucom (${(order.marketplaceFeePercentage ?? 0).toStringAsFixed(1)}%)',
                      style: const TextStyle(color: Colors.red),
                    ),
                    Text(
                      '-\$${(order.marketplaceFeeAmount ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              if (order.mpProcessingFee != null && order.mpProcessingFee! > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Comisión MP', style: TextStyle(color: Colors.red)),
                    Text(
                      '-\$${order.mpProcessingFee!.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              const Divider(),
              if (order.netAmount != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Neto que recibís', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    Text(
                      '\$${order.netAmount!.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total pagado por el cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '\$${(order.total ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (order.operationID != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Text('Operación: ${order.operationID}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
              if (order.paymentUrl != null) ...[
                const SizedBox(height: 4),
                SelectableText(
                  'URL de pago: ${order.paymentUrl}',
                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _mapPaymentStatusToLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Pago aprobado';
      case 'pending':
        return 'Pendiente de pago';
      case 'rejected':
        return 'Pago rechazado';
      case 'refunded':
        return 'Reembolsado';
      default:
        return status;
    }
  }
}

