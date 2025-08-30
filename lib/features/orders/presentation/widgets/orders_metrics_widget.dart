import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../getx/orders_controller.dart';

/// Widget que muestra estadísticas y métricas de las órdenes
class OrdersMetricsWidget extends StatelessWidget {
  const OrdersMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<OrdersController>(
      builder: (controller) {
        final orders = controller.orders;

        if (orders.isEmpty) {
          return const SizedBox.shrink();
        }

        // Calcular métricas
        final totalOrders = orders.length;
        final pendingOrders = orders.where((order) => order.estado == 'Pendiente').length;
        final completedOrders = orders.where((order) => order.estado == 'Completado').length;
        final inProgressOrders = orders.where((order) => order.estado == 'En curso').length;

        final totalRevenue = orders.fold<double>(0, (sum, order) => sum + (order.totalCentavos / 100));

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 768;
            final isTablet = screenWidth >= 768 && screenWidth < 1024;

            return Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Órdenes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 16 : 18,
                        ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),

                  // Métricas principales - responsive layout
                  if (isMobile)
                    _buildMobileMetrics(
                      context,
                      totalOrders,
                      pendingOrders,
                      inProgressOrders,
                      completedOrders,
                    )
                  else
                    _buildDesktopMetrics(
                      context,
                      isTablet,
                      totalOrders,
                      pendingOrders,
                      inProgressOrders,
                      completedOrders,
                    ),

                  SizedBox(height: isMobile ? 8 : 12),

                  // Ingresos totales
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FluentIcons.money_24_regular,
                          color: Colors.green[700],
                          size: isMobile ? 18 : 20,
                        ),
                        SizedBox(width: isMobile ? 6 : 8),
                        Expanded(
                          child: Text(
                            'Ingresos Totales: \$${totalRevenue.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMobileMetrics(
    BuildContext context,
    int totalOrders,
    int pendingOrders,
    int inProgressOrders,
    int completedOrders,
  ) {
    // En móvil, mostrar en 2x2 grid para mejor aprovechamiento del espacio
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total',
                totalOrders.toString(),
                FluentIcons.receipt_24_regular,
                Colors.blue,
                true, // isMobile
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                context,
                'Pendientes',
                pendingOrders.toString(),
                FluentIcons.hourglass_24_regular,
                Colors.orange,
                true, // isMobile
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'En Curso',
                inProgressOrders.toString(),
                FluentIcons.arrow_sync_24_regular,
                Colors.purple,
                true, // isMobile
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                context,
                'Completadas',
                completedOrders.toString(),
                FluentIcons.checkmark_circle_24_regular,
                Colors.green,
                true, // isMobile
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopMetrics(
    BuildContext context,
    bool isTablet,
    int totalOrders,
    int pendingOrders,
    int inProgressOrders,
    int completedOrders,
  ) {
    // En desktop/tablet, mostrar en una fila horizontal
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Total',
            totalOrders.toString(),
            FluentIcons.receipt_24_regular,
            Colors.blue,
            false, // not mobile
          ),
        ),
        SizedBox(width: isTablet ? 8 : 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Pendientes',
            pendingOrders.toString(),
            FluentIcons.hourglass_24_regular,
            Colors.orange,
            false, // not mobile
          ),
        ),
        SizedBox(width: isTablet ? 8 : 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'En Curso',
            inProgressOrders.toString(),
            FluentIcons.arrow_sync_24_regular,
            Colors.purple,
            false, // not mobile
          ),
        ),
        SizedBox(width: isTablet ? 8 : 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Completadas',
            completedOrders.toString(),
            FluentIcons.checkmark_circle_24_regular,
            Colors.green,
            false, // not mobile
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    MaterialColor color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: color[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
