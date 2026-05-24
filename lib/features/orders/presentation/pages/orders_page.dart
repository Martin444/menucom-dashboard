import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/orders/getx/orders_controller.dart';
import 'package:pickmeup_dashboard/features/orders/presentation/widgets/orders_metrics_widget.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrdersController ordersController;
  late final DinningController dinningController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Inicializar controladores
    ordersController = Get.put(OrdersController());
    dinningController = Get.find<DinningController>();

    // Cargar órdenes al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });

    // Escuchar el scroll para paginación (Issue 2.1.2)
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!ordersController.isLoading.value && ordersController.hasMore.value) {
        final userId = dinningController.dinningLogin.id;
        if (userId != null && userId.isNotEmpty) {
          ordersController.fetchOrdersByBusinessOwner(userId, refresh: false);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final userId = dinningController.dinningLogin.id;
    if (userId != null && userId.isNotEmpty) {
      await ordersController.fetchOrdersByBusinessOwner(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Definir breakpoints
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;

        if (isMobile) {
          // Layout móvil: MenuSide como drawer + contenido full width
          return Scaffold(
            drawer: const MenuSide(isMobile: true),
            appBar: AppBar(
              title: const Text('Órdenes'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(FluentIcons.line_horizontal_3_24_regular),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _loadOrders,
                  icon: const Icon(FluentIcons.arrow_sync_24_regular),
                  tooltip: 'Actualizar órdenes',
                ),
              ],
            ),
            body: _buildMobileContent(),
          );
        } else {
          // Layout tablet/desktop: MenuSide fijo + contenido expandido
          return Scaffold(
            body: Row(
              children: [
                // MenuSide con ancho fijo
                SizedBox(
                  width: isTablet ? 200 : 250,
                  child: const MenuSide(isMobile: false),
                ),
                // Contenido principal expandido
                Expanded(
                  child: _buildDesktopContent(isTablet),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildMobileContent() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget de métricas - versión móvil compacta
            OrdersMetricsWidget(orders: ordersController.orders),
            const SizedBox(height: 16),
            // Tabla/lista de órdenes
            _buildOrdersContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopContent(bool isTablet) {
    final horizontalPadding = isTablet ? 24.0 : 32.0;
    final verticalPadding = isTablet ? 16.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y botón de refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Órdenes',
                style: PuTextStyle.title1.copyWith(
                  fontSize: isTablet ? 24 : 32,
                  color: PUColors.textColorRich,
                ),
              ),
              IconButton(
                onPressed: _loadOrders,
                icon: const Icon(FluentIcons.arrow_sync_24_regular),
                tooltip: 'Actualizar órdenes',
                iconSize: isTablet ? 20 : 24,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 20),
          // Widget de métricas - versión desktop
          OrdersMetricsWidget(orders: ordersController.orders),
          SizedBox(height: isTablet ? 16 : 20),
          // Tabla de órdenes expandida
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _buildOrdersContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent() {
    return GetX<OrdersController>(
      builder: (controller) {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return _buildSkeletonLoader();
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.error_circle_24_regular,
                  size: 64,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar órdenes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadOrders,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.receipt_24_regular,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay órdenes disponibles',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Las órdenes aparecerán aquí cuando los clientes realicen pedidos.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadOrders,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            OrdersTable(
              data: controller.orders,
              onViewDetail: (order) {
                _showOrderDetailDialog(order);
              },
            ),
            if (controller.isLoading.value && controller.orders.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!controller.hasMore.value && controller.orders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No hay más órdenes para mostrar',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
          ],
        );
      },
    );
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

    Get.dialog(
      AlertDialog(
        title: Text('Detalle de Orden #${order.numero}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cliente: ${order.alias}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (order.customerEmail != null)
                    Text(order.customerEmail!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              if (order.customerPhone != null)
                Text('Tel: ${order.customerPhone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusBadge(order.estado),
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
              const Divider(),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...order.fullItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.productName}'),
                    Text('\$${item.price.toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(),
              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('\$${(order.subtotalCentavos / 100).toStringAsFixed(2)}'),
                ],
              ),
              // Marketplace fee
              if (order.marketplaceFeeAmountCentavos > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Comisión Menucom (${order.marketplaceFeePercentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(color: Colors.red)),
                    Text('-\$${(order.marketplaceFeeAmountCentavos / 100).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              // MP processing fee
              if (order.mpProcessingFeeCentavos != null && order.mpProcessingFeeCentavos! > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Comisión MP', style: TextStyle(color: Colors.red)),
                    Text('-\$${(order.mpProcessingFeeCentavos! / 100).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              const Divider(),
              // Net amount
              if (order.netAmountCentavos != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Neto que recibís', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    Text('\$${(order.netAmountCentavos! / 100).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total pagado por el cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$${(order.totalCentavos / 100).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
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

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PUColors.primaryBlue.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PUColors.primaryBlue.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
