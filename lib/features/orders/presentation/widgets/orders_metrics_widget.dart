import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de Órdenes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Total',
                      totalOrders.toString(),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Pendientes',
                      pendingOrders.toString(),
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'En Curso',
                      inProgressOrders.toString(),
                      Icons.autorenew,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Completadas',
                      completedOrders.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Ingresos Totales: \$${totalRevenue.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color[600],
            ),
          ),
        ],
      ),
    );
  }
}
