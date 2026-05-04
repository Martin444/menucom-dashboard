import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/orders/models/order_model.dart';
import 'package:menu_dart_api/by_feature/orders/usescase/count_orders_admin_usecase.dart';
import 'package:menu_dart_api/by_feature/orders/usescase/get_total_revenue_usecase.dart';
import 'package:menu_dart_api/by_feature/orders/usescase/order_usescase.dart';
import 'package:menu_dart_api/by_feature/user/count_users_admin/data/usecase/count_users_admin_usecase.dart';
import 'package:menu_dart_api/by_feature/user/count_users_admin/model/count_users_admin_params.dart';

import 'package:menu_dart_api/by_feature/user/count_users_admin/model/count_users_admin_response.dart';

class AdminDashboardController extends GetxController {
  final selectedIndex = 0.obs;
  final dashboardData = <String, dynamic>{
    'totalUsers': 0,
    'totalOrders': 0,
    'revenue': 0.0,
    'activeSessions': 0,
  }.obs;
  
  final recentOrders = <Order>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final searchResults = <Order>[].obs;
  
  // Pagination
  final currentPage = 1.obs;
  final pageSize = 10.obs;
  final hasMore = true.obs;

  // Computed
  List<Order> get ordersToDisplay => searchQuery.isEmpty ? recentOrders : searchResults;

  // Use Cases
  final _countOrdersUseCase = CountOrdersAdminUseCase();
  final _revenueUseCase = GetTotalRevenueUseCase();
  final _getOrdersUseCase = GetOrdersAdminUseCase();
  final _countUsersUseCase = CountUsersAdminUseCase();

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> search(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    isLoading.value = true;
    try {
      // For now, filtering locally as the API doesn't seem to have a search endpoint for orders yet
      searchResults.value = recentOrders
          .where((o) =>
              (o.id ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (o.ownerId ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (o.customerName ?? '').toLowerCase().contains(query.toLowerCase()) ||
              (o.customerEmail ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('Error searching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // Create independent tasks to avoid one failure blocking everything
      final tasks = [
        _safeCall(() => _countUsersUseCase.call(const CountUsersAdminParams())),
        _safeCall(() => _countOrdersUseCase.execute()),
        _safeCall(() => _revenueUseCase.execute()),
        _safeCall(() => _getOrdersUseCase.call(page: currentPage.value, limit: pageSize.value)),
      ];

      final results = await Future.wait(tasks);

      // Handle users count
      int usersCount = 0;
      if (results[0] is CountUsersAdminResponse) {
        usersCount = (results[0] as CountUsersAdminResponse).count;
      }

      // Handle orders count
      final ordersCount = results[1] as int? ?? 0;

      // Handle revenue
      final revenue = results[2] as double? ?? 0.0;

      // Handle orders list
      final ordersList = results[3] as List<Order>? ?? [];

      dashboardData.value = {
        'totalUsers': usersCount,
        'totalOrders': ordersCount,
        'revenue': revenue,
        'activeSessions': 0,
      };

      recentOrders.value = ordersList;
      hasMore.value = ordersList.isNotEmpty && ordersList.length == pageSize.value;
      
      debugPrint('Dashboard data loaded: ${recentOrders.length} orders');
    } catch (e) {
      debugPrint('Unexpected error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Safely executes a future, returning null on error instead of throwing
  Future<T?> _safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      debugPrint('Error in dashboard sub-task: $e');
      return null;
    }
  }

  Future<void> changePage(int page) async {
    if (page < 1) return;
    currentPage.value = page;
    await loadRecentOrders();
  }

  Future<void> loadRecentOrders() async {
    isLoading.value = true;
    try {
      final orders = await _getOrdersUseCase.call(
        page: currentPage.value,
        limit: pageSize.value,
      );
      recentOrders.value = orders;
      hasMore.value = orders.length == pageSize.value;
    } catch (e) {
      debugPrint('Error loading orders: $e');
      Get.snackbar('Error', 'No se pudieron cargar las órdenes');
    } finally {
      isLoading.value = false;
    }
  }
}