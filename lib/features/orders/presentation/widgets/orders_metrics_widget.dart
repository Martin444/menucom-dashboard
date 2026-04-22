import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../../getx/orders_controller.dart';

/// Widget que muestra estadísticas y métricas de las órdenes con diseño premium
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    totalOrders,
                    pendingOrders,
                    inProgressOrders,
                    completedOrders,
                  ),

                const SizedBox(height: 16),

                // Ingresos totales - Diseño Premium
                _buildRevenueCard(context, totalRevenue, isMobile),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRevenueCard(BuildContext context, double totalRevenue, bool isMobile) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FluentIcons.money_24_filled,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresos Totales',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${totalRevenue.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Bruto',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileMetrics(
    BuildContext context,
    int totalOrders,
    int pendingOrders,
    int inProgressOrders,
    int completedOrders,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _buildMetricCard(context, 'Total', totalOrders.toString(), FluentIcons.receipt_24_regular, Colors.blue),
        _buildMetricCard(
            context, 'Pendientes', pendingOrders.toString(), FluentIcons.hourglass_24_regular, Colors.orange),
        _buildMetricCard(
            context, 'En Curso', inProgressOrders.toString(), FluentIcons.arrow_sync_24_regular, Colors.purple),
        _buildMetricCard(
            context, 'Completadas', completedOrders.toString(), FluentIcons.checkmark_circle_24_regular, Colors.green),
      ],
    );
  }

  Widget _buildDesktopMetrics(
    BuildContext context,
    int totalOrders,
    int pendingOrders,
    int inProgressOrders,
    int completedOrders,
  ) {
    return Row(
      children: [
        Expanded(
            child: _buildMetricCard(
                context, 'Total', totalOrders.toString(), FluentIcons.receipt_24_regular, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildMetricCard(
                context, 'Pendientes', pendingOrders.toString(), FluentIcons.hourglass_24_regular, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildMetricCard(
                context, 'En Curso', inProgressOrders.toString(), FluentIcons.arrow_sync_24_regular, Colors.purple)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildMetricCard(context, 'Completadas', completedOrders.toString(),
                FluentIcons.checkmark_circle_24_regular, Colors.green)),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
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
