import 'package:get/get.dart';

class Order {
  final String id;
  final String description;
  final double total;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.description,
    required this.total,
    required this.createdAt,
  });
}

class OrdersController extends GetxController {
  // Lista reactiva de órdenes
  var orders = <Order>[].obs;

  // Estado de carga
  var isLoading = false.obs;

  // Obtener todas las órdenes (simulación)
  Future<void> fetchOrders() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    orders.value = [
      Order(
        id: '1',
        description: 'Orden 1',
        total: 25.0,
        createdAt: DateTime.now(),
      ),
      Order(
        id: '2',
        description: 'Orden 2',
        total: 40.5,
        createdAt: DateTime.now(),
      ),
    ];
    isLoading.value = false;
  }

  // Agregar una nueva orden
  void addOrder(Order order) {
    orders.add(order);
  }

  // Eliminar una orden por id
  void removeOrder(String id) {
    orders.removeWhere((order) => order.id == id);
  }

  // Buscar una orden por id
  Order? getOrderById(String id) {
    return orders.firstWhereOrNull((order) => order.id == id);
  }
}
