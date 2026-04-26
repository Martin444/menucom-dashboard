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
import 'package:menu_dart_api/by_feature/membership/models/billing_details_model.dart';
import 'package:menu_dart_api/by_feature/membership/models/payment_link_model.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/generate_payment_link_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/enable_auto_billing_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/get_billing_details_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/change_billing_amount_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/migrate_to_auto_billing_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/migrate_to_manual_billing_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/manage_user_subscription_usecase.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';

class UsersController extends GetxController {
  final getAllUsersUseCase = GetAllUsersAdminUseCase();
  final countUsersUseCase = CountUsersAdminUseCase();
  final deleteUserUseCase = DeleteUserUseCase();
  final updateUserAdminUseCase = UpdateUserAdminUseCase();
  final assignPlanToUserUseCase = AssignPlanToUserUseCase();
  final getAllAdminPlansUseCase = GetAllAdminPlansUseCase();

  late final GeneratePaymentLinkUseCase generatePaymentLinkUseCase;
  late final EnableAutoBillingUseCase enableAutoBillingUseCase;
  late final GetBillingDetailsUseCase getBillingDetailsUseCase;
  late final ChangeBillingAmountUseCase changeBillingAmountUseCase;
  late final MigrateToAutoBillingUseCase migrateToAutoBillingUseCase;
  late final MigrateToManualBillingUseCase migrateToManualBillingUseCase;
  late final ManageUserSubscriptionUseCase manageUserSubscriptionUseCase;

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

  final currentBillingDetails = Rx<BillingDetailsModel?>(null);
  final isLoadingBilling = false.obs;
  final selectedMembershipId = ''.obs;

  UsersController() {
    final provider = MembershipProvider();
    generatePaymentLinkUseCase = GeneratePaymentLinkUseCase(provider);
    enableAutoBillingUseCase = EnableAutoBillingUseCase(provider);
    getBillingDetailsUseCase = GetBillingDetailsUseCase(provider);
    changeBillingAmountUseCase = ChangeBillingAmountUseCase(provider);
    migrateToAutoBillingUseCase = MigrateToAutoBillingUseCase(provider);
    migrateToManualBillingUseCase = MigrateToManualBillingUseCase(provider);
    manageUserSubscriptionUseCase = ManageUserSubscriptionUseCase(provider);
  }

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

  Future<void> updateUser(UpdateUserRequest request) async {
    isLoading.value = true;
    try {
      final response = await updateUserAdminUseCase.call(request);
      if (response.success) {
        Get.snackbar(
          'Éxito',
          'Usuario actualizado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
        loadUsers();
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error inesperado: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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
        );
        loadUsers();
        loadCounts();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el usuario: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Navigation/Callback Methods
  // (No crean widgets, solo navigan o callbacks)
  // ============================================

  void showCreateUserDialog() {
    Get.snackbar(
      'Crear usuario',
      'Funcionalidad en desarrollo',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  final selectedUserForDetails = Rx<UserByRoleModel?>(null);

  void showUserDetails(UserByRoleModel user) {
    selectedUserForDetails.value = user;
  }

  void showEditUserDialog(UserByRoleModel user) {
    selectedUserForDetails.value = user;
  }

  void confirmDeleteUser(UserByRoleModel user) {
    selectedUserForDetails.value = user;
  }

  Future<void> assignMembership(String userId, String plan) async {
    isAssigningMembership.value = true;
    try {
      await assignPlanToUserUseCase.call(userId, plan);
      Get.snackbar(
        'Éxito',
        'Membresía asignada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadUsers();
      loadCounts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al asignar membresía: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAssigningMembership.value = false;
    }
  }

  Future<void> loadBillingDetails(String membershipId) async {
    isLoadingBilling.value = true;
    selectedMembershipId.value = membershipId;
    try {
      final details = await getBillingDetailsUseCase.execute(membershipId);
      currentBillingDetails.value = details;
    } catch (e) {
      debugPrint('Error loading billing details: $e');
      currentBillingDetails.value = null;
    } finally {
      isLoadingBilling.value = false;
    }
  }

  Future<BillingDetailsModel?> getBillingDetails(String membershipId) async {
    return getBillingDetailsUseCase.execute(membershipId);
  }

  Future<PaymentLinkModel> generatePaymentLink({
    required String userId,
    required String plan,
    required double amount,
    int periodMonths = 1,
    String? description,
  }) async {
    isLoadingBilling.value = true;
    try {
      final result = await generatePaymentLinkUseCase.execute(
        userId: userId,
        plan: plan,
        amount: amount,
        periodMonths: periodMonths,
        description: description,
      );
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Link Generado',
        message: 'El link de pago se ha generado correctamente',
      );
      return result;
    } catch (e) {
      _showBillingError(e);
      rethrow;
    } finally {
      isLoadingBilling.value = false;
    }
  }

  Future<AutoBillingResponseModel> enableAutoBilling({
    required String userId,
    required String plan,
    required String cardTokenId,
    double? amount,
  }) async {
    isLoadingBilling.value = true;
    try {
      final result = await enableAutoBillingUseCase.execute(
        userId: userId,
        plan: plan,
        cardTokenId: cardTokenId,
        amount: amount,
      );
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Auto-Billing Habilitado',
        message: 'La suscripción automática está activa',
      );
      return result;
    } catch (e) {
      _showBillingError(e);
      rethrow;
    } finally {
      isLoadingBilling.value = false;
    }
  }

  Future<ChangeAmountResponseModel> changeBillingAmount({
    required String membershipId,
    required double newAmount,
  }) async {
    isLoadingBilling.value = true;
    try {
      final result = await changeBillingAmountUseCase.execute(
        membershipId: membershipId,
        newAmount: newAmount,
      );
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Monto Actualizado',
        message: 'El monto de facturación se ha actualizado',
      );
      return result;
    } catch (e) {
      _showBillingError(e);
      rethrow;
    } finally {
      isLoadingBilling.value = false;
    }
  }

  Future<void> migrateToManualBilling(String membershipId) async {
    isLoadingBilling.value = true;
    try {
      await migrateToManualBillingUseCase.execute(membershipId);
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Migración Exitosa',
        message: 'La membresía ahora usa facturación manual',
      );
    } catch (e) {
      _showBillingError(e);
    } finally {
      isLoadingBilling.value = false;
    }
  }

  Future<void> migrateToAutoBilling({
    required String membershipId,
    required String cardTokenId,
  }) async {
    isLoadingBilling.value = true;
    try {
      await migrateToAutoBillingUseCase.execute(
        membershipId: membershipId,
        cardTokenId: cardTokenId,
      );
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Migración Exitosa',
        message: 'La membresía ahora usa facturación automática',
      );
    } catch (e) {
      _showBillingError(e);
    } finally {
      isLoadingBilling.value = false;
    }
  }

  Future<void> pauseSubscription(String membershipId) async {
    isLoadingBilling.value = true;
    try {
      await manageUserSubscriptionUseCase.pause(membershipId);
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Suscripción Pausada',
        message: 'La suscripción ha sido pausada',
      );
    } catch (e) {
      _showBillingError(e);
    } finally {
      isLoadingBilling.value = false;
    }
  }

  Future<void> resumeSubscription(String membershipId) async {
    isLoadingBilling.value = true;
    try {
      await manageUserSubscriptionUseCase.resume(membershipId);
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Suscripción Reanudada',
        message: 'La suscripción ha sido reanudada',
      );
    } catch (e) {
      _showBillingError(e);
    } finally {
      isLoadingBilling.value = false;
    }
  }

  void _showBillingError(dynamic e) {
    String message = 'Error de facturación';
    try {
      if (e.toString().contains('{')) {
        final start = e.toString().indexOf('{');
        final end = e.toString().lastIndexOf('}') + 1;
        final decoded = Map<String, dynamic>.from(
          (e.toString().substring(start, end)).isNotEmpty ? {} : {},
        );
        message = decoded['message'] ?? message;
      }
    } catch (_) {}
    GlobalDialogsHandles.snackbarError(
      title: 'Error',
      message: message,
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}