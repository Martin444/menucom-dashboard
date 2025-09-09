import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:menu_dart_api/menu_com_api.dart' as api;
import 'package:pu_material/pu_material.dart' as ui;

class OrdersController extends GetxController {
  // Lista reactiva de órdenes (usando el modelo del UI)
  var orders = <ui.Order>[].obs;

  // Estado de carga
  var isLoading = false.obs;

  // Error state
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Instancia del caso de uso
  final _getOrdersByBusinessOwnerUseCase = api.GetOrdersByBusinessOwnerUseCase();

  // Obtener órdenes por business owner ID
  Future<void> fetchOrdersByBusinessOwner(String businessOwnerId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Llamar al caso de uso del API
      final List<api.Order> apiOrders = await _getOrdersByBusinessOwnerUseCase.call(businessOwnerId);

      // Convertir órdenes del API al modelo del UI
      final List<ui.Order> uiOrders = apiOrders.map((apiOrder) => _convertApiOrderToUiOrder(apiOrder)).toList();

      // Actualizar la lista reactiva
      orders.assignAll(uiOrders);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar órdenes: $e';
      debugPrint('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método legacy para compatibilidad (simulación)
  Future<void> fetchOrders() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    orders.value = [
      ui.Order.example(
        numero: '001',
        detalle: 'Orden de ejemplo 1',
        estado: 'Pendiente',
        totalCentavos: 2500,
      ),
      ui.Order.example(
        numero: '002',
        detalle: 'Orden de ejemplo 2',
        estado: 'Completado',
        totalCentavos: 4050,
      ),
    ];
    isLoading.value = false;
  }

  // Convertir Order del API a Order del UI
  ui.Order _convertApiOrderToUiOrder(api.Order apiOrder) {
    // Generar detalles a partir de los items
    String detalles = '';
    if (apiOrder.items != null && apiOrder.items!.isNotEmpty) {
      detalles = apiOrder.items!.map((item) => '${item.quantity}x ${item.productName}').join(', ');
    } else {
      detalles = 'Sin detalles disponibles';
    }

    // Convertir total a centavos
    int totalCentavos = ((apiOrder.total ?? 0.0) * 100).round();

    return ui.Order(
      numero: apiOrder.id?.substring(0, 8) ?? 'N/A', // Usar primeros 8 chars del ID
      detalle: detalles,
      estado: _mapApiStatusToUiStatus(apiOrder.status),
      creado: apiOrder.createdAt ?? DateTime.now(),
      alias: apiOrder.customerEmail?.split('@').first ?? 'Cliente', // Usar parte del email como alias
      idCliente: apiOrder.customerEmail ?? apiOrder.customerPhone ?? 'Sin identificar',
      totalCentavos: totalCentavos,
    );
  }

  // Mapear estados del API a estados del UI
  String _mapApiStatusToUiStatus(String? apiStatus) {
    switch (apiStatus?.toLowerCase()) {
      case 'pending':
      case 'created':
        return 'Pendiente';
      case 'processing':
      case 'in_progress':
        return 'En curso';
      case 'completed':
      case 'finished':
        return 'Completado';
      case 'cancelled':
      case 'canceled':
        return 'Cancelado';
      case 'failed':
        return 'Fallido';
      default:
        return apiStatus ?? 'Desconocido';
    }
  }

  // Agregar una nueva orden (para futuras funcionalidades)
  void addOrder(ui.Order order) {
    orders.add(order);
  }

  // Eliminar una orden por número
  void removeOrder(String numero) {
    orders.removeWhere((order) => order.numero == numero);
  }

  // Buscar una orden por número
  ui.Order? getOrderByNumero(String numero) {
    return orders.firstWhereOrNull((order) => order.numero == numero);
  }

  // Limpiar órdenes
  void clearOrders() {
    orders.clear();
  }

  // Refrescar órdenes
  Future<void> refreshOrders(String businessOwnerId) async {
    await fetchOrdersByBusinessOwner(businessOwnerId);
  }
}
