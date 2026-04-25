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
import 'package:menu_dart_api/by_feature/user/update_user_admin/update_user_admin.dart';
import 'package:menu_dart_api/by_feature/user/update_user/model/update_user_request.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/assign_plan_to_user_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/get_all_admin_plans_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/provider/membership_provider.dart';
import 'package:menu_dart_api/by_feature/membership/models/membership_plan_model.dart';

class UsersController extends GetxController {
  final getAllUsersUseCase = GetAllUsersAdminUseCase();
  final countUsersUseCase = CountUsersAdminUseCase();
  final deleteUserUseCase = DeleteUserUseCase();
  final updateUserAdminUseCase = UpdateUserAdminUseCase();
  final assignPlanToUserUseCase = AssignPlanToUserUseCase();
  final getAllAdminPlansUseCase = GetAllAdminPlansUseCase();

  final searchController = TextEditingController();

  final users = <UserByRoleModel>[].obs;
  final availablePlans = <MembershipPlanModel>[].obs;
  final isLoading = false.obs;
  final isAssigningMembership = false.obs;
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
    loadAvailablePlans();
  }

  Future<void> loadAvailablePlans() async {
    try {
      final plans = await getAllAdminPlansUseCase.call();
      availablePlans.value = plans;
    } catch (e) {
      debugPrint('Error loading available plans: $e');
      // No bloqueamos la UI pero informamos al usuario si intenta asignar
    }
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
        plan: selectedPlan.value.isNotEmpty ? MembershipPlanFilter.fromString(selectedPlan.value) : null,
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
            onPressed: () {
              Get.back();
              showAssignMembershipDialog(user);
            },
            child: const Text('Asignar Membresía'),
          ),
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
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    final needToChangePassword = (user.needToChangepassword == true).obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Editar Usuario'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ingrese el nombre completo',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'usuario@ejemplo.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '+54 9 11 1234-5678',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Obx(() => CheckboxListTile(
                      title: const Text('Forzar cambio de contraseña'),
                      subtitle: const Text('El usuario deberá cambiar su clave en el próximo ingreso'),
                      value: needToChangePassword.value,
                      onChanged: (val) => needToChangePassword.value = val ?? false,
                      contentPadding: EdgeInsets.zero,
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final request = UpdateUserRequest(
                  userId: user.id!,
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  needToChangePassword: needToChangePassword.value,
                );
                Get.back();
                await updateUser(request);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> updateUser(UpdateUserRequest request) async {
    isLoading.value = true;
    try {
      final response = await updateUserAdminUseCase.call(request);
      if (response.success) {
        Get.snackbar(
          'Éxito',
          'Usuario actualizado correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        loadUsers();
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error inesperado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
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

  Future<void> assignMembership(String userId, String plan) async {
    isAssigningMembership.value = true;
    try {
      await assignPlanToUserUseCase.call(userId, plan);
      Get.snackbar(
        'Éxito',
        'Membresía asignada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      loadUsers();
      loadCounts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al asignar membresía: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isAssigningMembership.value = false;
    }
  }

  void showAssignMembershipDialog(UserByRoleModel user) {
    if (availablePlans.isEmpty) {
      Get.snackbar('Error', 'No hay planes disponibles para asignar');
      return;
    }

    final selectedPlanToAssign = Rx<String>(availablePlans.first.name);

    Get.dialog(
      AlertDialog(
        title: Text('Asignar Membresía a ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Seleccione el plan que desea asignar manualmente al usuario. Esto sobreescribirá su membresía actual.'),
            const SizedBox(height: 20),
            Obx(() => DropdownButtonFormField<String>(
                  value: selectedPlanToAssign.value,
                  decoration: const InputDecoration(
                    labelText: 'Plan de Membresía',
                    border: OutlineInputBorder(),
                  ),
                  items: availablePlans.map((plan) {
                    return DropdownMenuItem(
                      value: plan.name,
                      child: Text(plan.displayName ?? plan.name),
                    );
                  }).toList(),
                  onChanged: (val) => selectedPlanToAssign.value = val!,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          Obx(() => ElevatedButton(
                onPressed: isAssigningMembership.value
                    ? null
                    : () {
                        Get.back();
                        assignMembership(user.id!, selectedPlanToAssign.value);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: isAssigningMembership.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Asignar Plan'),
              )),
        ],
      ),
    );
  }
}
