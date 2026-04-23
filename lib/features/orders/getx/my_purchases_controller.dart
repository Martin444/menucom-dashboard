import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:menu_dart_api/menu_com_api.dart' as api;
import 'package:pu_material/pu_material.dart' as ui;

class MyPurchasesController extends GetxController {
  var purchases = <ui.Order>[].obs;

  var isLoading = false.obs;

  var hasError = false.obs;
  var errorMessage = ''.obs;

  final _getOrdersByOwnerUseCase = api.GetOrdersByOwnerUseCase();

  var currentPage = 1.obs;
  var pageSize = 20.obs;
  var hasMore = true.obs;

  Future<void> fetchPurchases({bool refresh = true}) async {
    try {
      if (refresh) {
        isLoading.value = true;
        currentPage.value = 1;
        purchases.clear();
        hasMore.value = true;
      }

      hasError.value = false;
      errorMessage.value = '';

      final List<api.Order> apiOrders = await _getOrdersByOwnerUseCase.call(
        page: currentPage.value,
        limit: pageSize.value,
      );

      if (apiOrders.isEmpty) {
        hasMore.value = false;
      } else {
        final List<ui.Order> uiOrders = apiOrders.map((apiOrder) => _convertApiOrderToUiOrder(apiOrder)).toList();

        if (refresh) {
          purchases.assignAll(uiOrders);
        } else {
          purchases.addAll(uiOrders);
        }
        
        currentPage.value++;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al cargar compras: $e';
      debugPrint('Error fetching purchases: $e');
    } finally {
      isLoading.value = false;
    }
  }

  ui.Order _convertApiOrderToUiOrder(api.Order apiOrder) {
    String detalles = '';
    if (apiOrder.items != null && apiOrder.items!.isNotEmpty) {
      detalles = apiOrder.items!.map((item) => '${item.quantity}x ${item.productName}').join(', ');
    } else {
      detalles = 'Sin detalles disponibles';
    }

    int totalCentavos = ((apiOrder.total ?? 0.0) * 100).round();

    return ui.Order(
      numero: (apiOrder.id != null && apiOrder.id!.length >= 8)
          ? apiOrder.id!.substring(0, 8)
          : (apiOrder.id ?? 'N/A'),
      detalle: detalles,
      estado: _mapApiStatusToUiStatus(apiOrder.status),
      creado: apiOrder.createdAt ?? DateTime.now(),
      alias: apiOrder.customerName != null 
          ? '${apiOrder.customerName} ${apiOrder.customerLastName ?? ''}'.trim()
          : (apiOrder.ownerId?.split('-').first ?? 'Tienda'),
      idCliente: apiOrder.ownerId ?? 'Sin identificar',
      totalCentavos: totalCentavos,
    );
  }

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
      case 'confirmed':
        return 'Completado';
      case 'cancelled':
      case 'canceled':
        return 'Cancelado';
      case 'failed':
        return 'Fallido';
      default:
        if (apiStatus != null && apiStatus.isNotEmpty) {
          return apiStatus[0].toUpperCase() + apiStatus.substring(1).toLowerCase();
        }
        return 'Desconocido';
    }
  }

  void addPurchase(ui.Order order) {
    purchases.add(order);
  }

  void removePurchase(String numero) {
    purchases.removeWhere((order) => order.numero == numero);
  }

  ui.Order? getPurchaseByNumero(String numero) {
    return purchases.firstWhereOrNull((order) => order.numero == numero);
  }

  void clearPurchases() {
    purchases.clear();
  }

  Future<void> refreshPurchases() async {
    await fetchPurchases();
  }
}