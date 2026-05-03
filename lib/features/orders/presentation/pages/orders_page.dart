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
            Expanded(
              child: OrdersTable(
                data: controller.orders,
              ),
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

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PUColors.primaryBlue.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PUColors.primaryBlue.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
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
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
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
                  color: Colors.grey.withValues(alpha: 0.1),
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
