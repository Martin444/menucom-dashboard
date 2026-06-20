import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/model/user_by_role_model.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/model/users_by_roles_params.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/data/usescase/get_users_by_roles_usecase.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';

class ClientsController extends GetxController {
  final getUsersByRolesUseCase = GetUsersByRolesUseCase();

  final searchController = TextEditingController();

  final clients = <UserByRoleModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final totalCount = 0.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final itemsPerPage = 20.obs;

  final selectedRole = Rx<String>('');
  final activeClientsCount = 0.obs;
  final newThisMonthCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
    loadCounts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    if (value.isEmpty) {
      loadClients();
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      loadClients();
    });
  }

  Future<void> loadClients() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final params = const UsersByRolesParams(
        roles: [RolesUsers.customer],
      );

      final response = await getUsersByRolesUseCase.execute(params);

      var filteredClients = List<UserByRoleModel>.from(response.users);

      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        filteredClients = filteredClients.where((c) {
          final name = (c.name ?? '').toLowerCase();
          final email = (c.email ?? '').toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList();
      }

      clients.value = filteredClients;
      totalCount.value = filteredClients.length;
      totalPages.value = (filteredClients.length / itemsPerPage.value).ceil();
      currentPage.value = 1;
    } catch (e) {
      errorMessage.value = 'Error al cargar clientes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCounts() async {
    try {
      final params = const UsersByRolesParams(
        roles: [RolesUsers.customer],
      );

      final response = await getUsersByRolesUseCase.execute(params);
      totalCount.value = response.total;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      newThisMonthCount.value = response.users.where((u) {
        if (u.createAt == null) return false;
        return u.createAt!.isAfter(startOfMonth);
      }).length;

      activeClientsCount.value = response.users.where((u) {
        return u.isEmailVerified == true;
      }).length;
    } catch (e) {
      debugPrint('Error loading client counts: $e');
    }
  }

  void filterByRole(String role) {
    selectedRole.value = role;
    loadClients();
  }

  List<UserByRoleModel> get paginatedClients {
    final start = (currentPage.value - 1) * itemsPerPage.value;
    final end = start + itemsPerPage.value;
    if (start >= clients.length) return [];
    return clients.sublist(start, end > clients.length ? clients.length : end);
  }

  void goToPage(int page) {
    currentPage.value = page;
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
