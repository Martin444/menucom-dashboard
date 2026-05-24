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

      final totalRevenue = orders
          .where((order) => order.estado == 'Completado' || order.estado == 'En curso' || order.estado == 'Confirmado' || order.estado == 'Entregado')
          .fold<double>(0, (sum, order) {
        if (order.netAmountCentavos != null) {
          return sum + (order.netAmountCentavos! / 100);
        }
        return sum + (order.totalCentavos / 100);
      });

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

              const SizedBox(height: 12),

              // Ingresos totales - Diseño Premium
              _buildRevenueCard(context, totalRevenue, isMobile),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    });
  }

  Widget _buildRevenueCard(BuildContext context, double totalRevenue, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ui.PUColors.primaryBlue,
            ui.PUColors.primaryBlueDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ui.PUColors.primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              FluentIcons.money_24_filled,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ingresos Totales',
                  style: ui.PuTextStyle.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  style: ui.PuTextStyle.title1.copyWith(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                'Neto',
                style: ui.PuTextStyle.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
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
        const SizedBox(width: 12),
        Expanded(
            child: _buildMetricCard(
                context, 'Pendientes', pendingOrders.toString(), FluentIcons.hourglass_24_regular, const Color(0xFFD97706))),
        const SizedBox(width: 12),
        Expanded(
            child: _buildMetricCard(
                context, 'En Curso', inProgressOrders.toString(), FluentIcons.arrow_sync_24_regular, const Color(0xFF7C3AED))),
        const SizedBox(width: 12),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    if (isDesktop) {
      return _buildDesktopMetricCard(context, label, value, icon, color);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
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
              color: color.withOpacity(0.1),
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
              color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildDesktopMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: ui.PuTextStyle.bodySmall.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: ui.PuTextStyle.title3.copyWith(
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
