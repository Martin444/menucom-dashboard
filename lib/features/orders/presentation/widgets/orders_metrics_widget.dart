import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart' as ui;
class OrdersMetricsWidget extends StatelessWidget {
  final List<ui.Order> orders;
  const OrdersMetricsWidget({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
    });
  }

  Widget _buildRevenueCard(BuildContext context, double totalRevenue, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ui.PUColors.primaryBlue,
            ui.PUColors.primaryBlueDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ui.PUColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              FluentIcons.money_24_filled,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingresos Totales',
                  style: ui.PuTextStyle.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  style: ui.PuTextStyle.title1.copyWith(
                    color: Colors.white,
                    fontSize: isMobile ? 26 : 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Bruto',
                style: ui.PuTextStyle.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
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
        _buildMetricCard(context, 'Total', totalOrders.toString(), FluentIcons.receipt_24_regular, ui.PUColors.primaryBlue),
        _buildMetricCard(
            context, 'Pendientes', pendingOrders.toString(), FluentIcons.hourglass_24_regular, const Color(0xFFD97706)), // Amber-600
        _buildMetricCard(
            context, 'En Curso', inProgressOrders.toString(), FluentIcons.arrow_sync_24_regular, const Color(0xFF7C3AED)), // Violet-600
        _buildMetricCard(
            context, 'Completadas', completedOrders.toString(), FluentIcons.checkmark_circle_24_regular, const Color(0xFF059669)), // Emerald-600
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
                context, 'Total', totalOrders.toString(), FluentIcons.receipt_24_regular, ui.PUColors.primaryBlue)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildMetricCard(
                context, 'Pendientes', pendingOrders.toString(), FluentIcons.hourglass_24_regular, const Color(0xFFD97706))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildMetricCard(
                context, 'En Curso', inProgressOrders.toString(), FluentIcons.arrow_sync_24_regular, const Color(0xFF7C3AED))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildMetricCard(context, 'Completadas', completedOrders.toString(),
                FluentIcons.checkmark_circle_24_regular, const Color(0xFF059669))),
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
              style: ui.PuTextStyle.title3.copyWith(
                fontSize: 18,
                color: theme.colorScheme.onSurface,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: ui.PuTextStyle.bodySmall.copyWith(
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
