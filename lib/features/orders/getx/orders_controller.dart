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



  // Variables para paginación
  var currentPage = 1.obs;
  var pageSize = 20.obs;
  var hasMore = true.obs;

  // Obtener órdenes por business owner ID
  Future<void> fetchOrdersByBusinessOwner(String businessOwnerId, {bool refresh = true}) async {
    try {
      if (refresh) {
        isLoading.value = true;
        currentPage.value = 1;
        orders.clear();
        hasMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      // Llamar al caso de uso del API con paginación
      final List<api.Order> apiOrders = await _getOrdersByBusinessOwnerUseCase.call(
        businessOwnerId,
        page: currentPage.value,
        limit: pageSize.value,
      );

      if (apiOrders.isEmpty) {
        hasMore.value = false;
      } else {
        // Convertir órdenes del API al modelo del UI
        final List<ui.Order> uiOrders = apiOrders.map((apiOrder) => _convertApiOrderToUiOrder(apiOrder)).toList();

        // Actualizar la lista reactiva
        if (refresh) {
          orders.assignAll(uiOrders);
        } else {
          orders.addAll(uiOrders);
        }
        
        currentPage.value++;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar órdenes: $e';
      debugPrint('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Convertir Order del API a Order del UI
  ui.Order _convertApiOrderToUiOrder(api.Order apiOrder) {
    // Generar detalles a partir de los items
    String detalles = '';
    List<ui.OrderItem> uiItems = [];
    if (apiOrder.items != null && apiOrder.items!.isNotEmpty) {
      detalles = apiOrder.items!.map((item) => '${item.quantity}x ${item.productName}').join(', ');
      uiItems = apiOrder.items!
          .map((item) => ui.OrderItem(
                productName: item.productName ?? 'Sin nombre',
                quantity: item.quantity ?? 1,
                price: item.price ?? 0.0,
              ))
          .toList();
    } else {
      detalles = 'Sin detalles disponibles';
    }

    // Convertir total a centavos
    int totalCentavos = ((apiOrder.total ?? 0.0) * 100).round();

    return ui.Order(
      numero: (apiOrder.id != null && apiOrder.id!.length >= 8)
          ? apiOrder.id!.substring(0, 8)
          : (apiOrder.id ?? 'N/A'), // Usar primeros 8 chars del ID de forma segura
      detalle: detalles,
      estado: _mapApiStatusToUiStatus(apiOrder.status),
      creado: apiOrder.createdAt ?? DateTime.now(),
      alias: apiOrder.customerEmail?.split('@').first ?? 'Cliente', // Usar parte del email como alias
      idCliente: apiOrder.customerEmail ?? apiOrder.customerPhone ?? 'Sin identificar',
      totalCentavos: totalCentavos,
      paymentUrl: apiOrder.paymentUrl,
      customerEmail: apiOrder.customerEmail,
      customerPhone: apiOrder.customerPhone,
      operationId: apiOrder.operationID,
      fullItems: uiItems,
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
        if (apiStatus != null && apiStatus.isNotEmpty) {
          // Si el estado es nuevo, mostrarlo capitalizado en lugar de "Desconocido"
          return apiStatus[0].toUpperCase() + apiStatus.substring(1).toLowerCase();
        }
        return 'Desconocido';
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
