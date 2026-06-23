import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/orders/getx/my_purchases_controller.dart';
import 'package:pickmeup_dashboard/features/orders/presentation/widgets/orders_metrics_widget.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class MyPurchasesPage extends StatefulWidget {
  const MyPurchasesPage({super.key});

  @override
  State<MyPurchasesPage> createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  late final MyPurchasesController purchasesController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    purchasesController = Get.put(MyPurchasesController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchases();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!purchasesController.isLoading.value && purchasesController.hasMore.value) {
        purchasesController.fetchPurchases(refresh: false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPurchases() async {
    await purchasesController.fetchPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;

        if (isMobile) {
          return Scaffold(
            drawer: const MenuSide(isMobile: true),
            appBar: AppBar(
              title: const Text('Mis Compras'),
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
                  onPressed: _loadPurchases,
                  icon: const Icon(FluentIcons.arrow_sync_24_regular),
                  tooltip: 'Actualizar compras',
                ),
              ],
            ),
            body: _buildMobileContent(),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: isTablet ? 200 : 250,
                  child: const MenuSide(isMobile: false),
                ),
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
      onRefresh: _loadPurchases,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrdersMetricsWidget(orders: purchasesController.purchases),
            const SizedBox(height: 16),
            _buildPurchasesContent(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Compras',
                style: PuTextStyle.title1.copyWith(
                  fontSize: isTablet ? 24 : 32,
                  color: PUColors.textColorRich,
                ),
              ),
              IconButton(
                onPressed: _loadPurchases,
                icon: const Icon(FluentIcons.arrow_sync_24_regular),
                tooltip: 'Actualizar compras',
                iconSize: isTablet ? 20 : 24,
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 20),
          OrdersMetricsWidget(orders: purchasesController.purchases),
          SizedBox(height: isTablet ? 16 : 20),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _buildPurchasesContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesContent() {
    return GetX<MyPurchasesController>(
      builder: (controller) {
        if (controller.isLoading.value && controller.purchases.isEmpty) {
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
                  'Error al cargar compras',
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
                  onPressed: _loadPurchases,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (controller.purchases.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.cart_24_regular,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay compras disponibles',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Las compras aparecerán aquí cuando realices pedidos.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPurchases,
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            OrdersTable(
              data: controller.purchases,
              onViewDetail: (order) {
                _showPurchaseDetailDialog(order);
              },
            ),
            if (controller.isLoading.value && controller.purchases.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!controller.hasMore.value && controller.purchases.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No hay más compras para mostrar',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showPurchaseDetailDialog(Order order) {
    Get.dialog(
      AlertDialog(
        title: Text('Detalle de Compra #${order.numero}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tienda: ${order.alias}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  StatusBadge(order.estado),
                ],
              ),
              if (order.customerEmail != null) Text('Email: ${order.customerEmail}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (order.customerPhone != null) Text('Teléfono: ${order.customerPhone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (order.idCliente.isNotEmpty && order.idCliente != order.customerEmail)
                Text('ID: ${order.idCliente}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...order.fullItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.productName}'),
                    Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('\$${(order.subtotalCentavos / 100).toStringAsFixed(2)}'),
                ],
              ),
              const Divider(thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('\$${(order.totalCentavos / 100).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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


