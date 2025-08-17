import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/orders/getx/orders_controller.dart';
import 'package:pickmeup_dashboard/features/orders/presentation/widgets/orders_metrics_widget.dart';
import 'package:pu_material/pu_material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrdersController ordersController;
  late final DinningController dinningController;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores
    ordersController = Get.put(OrdersController());
    dinningController = Get.find<DinningController>();

    // Cargar órdenes al inicializar
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (dinningController.dinningLogin.id != null) {
      await ordersController.fetchOrdersByBusinessOwner(dinningController.dinningLogin.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MenuSide(
          isMobile: true,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.08,
              vertical: MediaQuery.of(context).size.height * 0.04,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Órdenes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: _loadOrders,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualizar órdenes',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Widget de métricas
                const OrdersMetricsWidget(),
                Expanded(
                  child: GetX<OrdersController>(
                    builder: (controller) {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (controller.hasError.value) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
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
                                Icons.receipt_long_outlined,
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

                      return OrdersTable(
                        padding: EdgeInsets.zero,
                        data: controller.orders,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
