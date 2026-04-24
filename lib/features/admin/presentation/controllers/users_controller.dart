import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/model/user_by_role_model.dart';
import 'package:menu_dart_api/by_feature/user/get_all_users_admin/model/get_all_users_admin_filters.dart';
import 'package:menu_dart_api/by_feature/user/get_all_users_admin/model/get_all_users_admin_params.dart';
import 'package:menu_dart_api/by_feature/user/get_all_users_admin/data/usecase/get_all_users_admin_usecase.dart';
import 'package:menu_dart_api/by_feature/user/count_users_admin/model/count_users_admin_filters.dart';
import 'package:menu_dart_api/by_feature/user/count_users_admin/model/count_users_admin_params.dart';
import 'package:menu_dart_api/by_feature/user/count_users_admin/data/usecase/count_users_admin_usecase.dart';
import 'package:menu_dart_api/by_feature/user/get_all_users_admin/model/membership_enums.dart';
import 'package:menu_dart_api/by_feature/user/delete_user/data/usecase/delete_user_usecase.dart';

class UsersController extends GetxController {
  final getAllUsersUseCase = GetAllUsersAdminUseCase();
  final countUsersUseCase = CountUsersAdminUseCase();
  final deleteUserUseCase = DeleteUserUseCase();

  final searchController = TextEditingController();

  final users = <UserByRoleModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final itemsPerPage = 20.obs;

  final selectedPlan = Rx<String>('');
  final withActiveMembership = false.obs;
  final withVinculedAccount = false.obs;

  final activeMembershipCount = 0.obs;
  final vinculedCount = 0.obs;
  final verifiedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadCounts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    if (value.isEmpty) {
      loadUsers();
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      loadUsers();
    });
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final filters = GetAllUsersAdminFilters(
        search: searchController.text.isNotEmpty ? searchController.text : null,
        plan: selectedPlan.value.isNotEmpty 
            ? MembershipPlanFilter.fromString(selectedPlan.value)
            : null,
        withActiveMembership: withActiveMembership.value ? true : null,
        withVinculedAccount: withVinculedAccount.value ? true : null,
        sortBy: SortByField.createdAt,
        sortOrder: SortOrder.desc,
        page: currentPage.value,
        limit: itemsPerPage.value,
      );

      final response = await getAllUsersUseCase.call(
        GetAllUsersAdminParams(filters: filters),
      );

      users.value = response.users;
      totalCount.value = response.total;
      totalPages.value = response.totalPages;
      currentPage.value = response.page;
    } catch (e) {
      errorMessage.value = 'Error al cargar usuarios: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCounts() async {
    try {
      final allCounts = await countUsersUseCase.call(
        const CountUsersAdminParams(),
      );
      totalCount.value = allCounts.count;

      final membershipCounts = await countUsersUseCase.call(
        const CountUsersAdminParams(
          filters: CountUsersAdminFilters(withActiveMembership: true),
        ),
      );
      activeMembershipCount.value = membershipCounts.count;

      final vinculedCounts = await countUsersUseCase.call(
        const CountUsersAdminParams(
          filters: CountUsersAdminFilters(withVinculedAccount: true),
        ),
      );
      vinculedCount.value = vinculedCounts.count;

      verifiedCount.value = 0;
    } catch (e) {
      debugPrint('Error loading counts: $e');
    }
  }

  void filterByPlan(String plan) {
    selectedPlan.value = plan;
    currentPage.value = 1;
    loadUsers();
  }

  void toggleActiveMembership() {
    withActiveMembership.value = !withActiveMembership.value;
    currentPage.value = 1;
    loadUsers();
  }

  void toggleVinculedAccount() {
    withVinculedAccount.value = !withVinculedAccount.value;
    currentPage.value = 1;
    loadUsers();
  }

  void goToPage(int page) {
    currentPage.value = page;
    loadUsers();
  }

  void changeItemsPerPage(int limit) {
    itemsPerPage.value = limit;
    currentPage.value = 1;
    loadUsers();
  }

  void showUserDetails(UserByRoleModel user) {
    Get.dialog(
      AlertDialog(
        title: Text(user.name ?? 'Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', user.email ?? '-'),
            _buildDetailRow('Teléfono', user.phone ?? '-'),
            _buildDetailRow('Rol', user.role ?? '-'),
            _buildDetailRow(
              'Membresía',
              user.membership?['plan']?.toString() ?? 'Sin membresía',
            ),
            _buildDetailRow('Verificado', user.isEmailVerified == true ? 'Sí' : 'No'),
            _buildDetailRow(
              'Creado',
              user.createAt?.toString() ?? '-',
            ),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void showCreateUserDialog() {
    Get.snackbar(
      'Crear usuario',
      'Funcionalidad en desarrollo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showEditUserDialog(UserByRoleModel user) {
    Get.snackbar(
      'Editar usuario',
      'Funcionalidad en desarrollo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void confirmDeleteUser(UserByRoleModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Estás seguro de eliminar a ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteUser(user.id!);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(String userId) async {
    isLoading.value = true;
    try {
      final success = await deleteUserUseCase.call(userId);
      if (success) {
        Get.snackbar(
          'Usuario eliminado',
          'El usuario ha sido eliminado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        loadUsers(); // Recargar la lista
        loadCounts(); // Actualizar contadores
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el usuario: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}