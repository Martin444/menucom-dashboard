import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

import '../../../helpers/token_helper.dart';
import '../../../core/navigation/menu_navigation_controller.dart';
import '../../../core/mixins/navigation_state_mixin.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class UserSessionController extends GetxController {
  DinningModel dinningLogin = DinningModel();

  RxBool isLoadingDataUser = true.obs;
  RxBool hasErrorLoadingUser = false.obs;
  RxBool everyListEmpty = true.obs;
  RxBool hasMissingLogo = false.obs;
  RxBool hasSelectedCommerce = false.obs;
  RxString currentUserRole = ''.obs;
  RxString currentContextType = ''.obs;

  bool get isCustomerRole {
    final role = RolesFuncionts.getTypeRoleByRoleString(dinningLogin.role ?? '');
    return role == RolesUsers.customer || role == RolesUsers.admin;
  }

  Future<String> getHashedAccessToken() async {
    final token = API.loginAccessToken;
    if (token.isEmpty) return '';
    return hashAccessToken(token);
  }

  void getMyDinningInfo() async {
    try {
      isLoadingDataUser.value = true;
      hasErrorLoadingUser.value = false;

      if (API.loginAccessToken.isEmpty) {
        debugPrint('UserSessionController: No hay token en memoria, abortando carga');
        hasErrorLoadingUser.value = true;
        isLoadingDataUser.value = false;
        update();
        return;
      }

      var respDinning = await GetDinningUseCase().execute();
      dinningLogin = respDinning;

      try {
        final contexts = await GetMyContextsUseCase().execute();
        final currentContext = contexts.firstWhereOrNull(
          (c) => c.isCurrent,
        );
        hasSelectedCommerce.value = currentContext != null;
        if (currentContext != null) {
          hasMissingLogo.value = currentContext.logoUrl == null;
          if (dinningLogin.commerceId == null || dinningLogin.commerceId!.isEmpty) {
            dinningLogin.commerceId = currentContext.id;
          }
          dinningLogin.businessName = currentContext.businessName;
          dinningLogin.slug = currentContext.slug;
          if (currentContext.logoUrl != null) {
            dinningLogin.photoURL = currentContext.logoUrl;
          }
          if (currentContext.coverImageUrl != null) {
            dinningLogin.coverImageUrl = currentContext.coverImageUrl;
          }
          if (currentContext.role != null) {
            currentUserRole.value = currentContext.role!;
          }
          if (currentContext.context != null) {
            currentContextType.value = currentContext.context!;
          }
        }
      } catch (e) {
        debugPrint('Error loading contexts: $e');
        hasSelectedCommerce.value = false;
      }

      final userRole = dinningLogin.role;
      if (userRole == null || userRole.isEmpty) {
        throw Exception('Rol de usuario no válido');
      }

      everyListEmpty.value = false;

      isLoadingDataUser.value = false;
      update();

      if (Get.isRegistered<MenuNavigationController>()) {
        Get.find<MenuNavigationController>().update();
      }
    } catch (e) {
      debugPrint('Error getting dinning info: $e');
      hasErrorLoadingUser.value = true;
      isLoadingDataUser.value = false;
      update();
    }
  }

  void clearData() {
    dinningLogin = DinningModel();
    currentUserRole.value = '';
    currentContextType.value = '';
    hasSelectedCommerce.value = false;
    everyListEmpty.value = true;
    update();
  }

  void closeSesion() async {
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    } else {
      clearData();
      API.setAccessToken('');
      Get.offAllNamed(PURoutes.LOGIN);
    }
  }

  @override
  void onReady() {
    super.onReady();
    syncNavigationState();
  }

  // ─── Users by roles ───
  List<UserByRoleModel> usersByRolesList = <UserByRoleModel>[];
  bool _isLoadingUsersByRoles = false;
  UsersByRolesResponse? lastUsersByRolesResponse;

  bool get isLoadingUsersByRoles => _isLoadingUsersByRoles;

  Future<List<UserByRoleModel>?> getUsersByRoles({
    required List<RolesUsers> roles,
    bool withVinculedAccount = false,
  }) async {
    if (_isLoadingUsersByRoles) {
      debugPrint('=== getUsersByRoles already in progress, skipping ===');
      return usersByRolesList;
    }

    try {
      _isLoadingUsersByRoles = true;
      usersByRolesList.clear();

      final params = UsersByRolesParams(
        roles: roles,
        withVinculedAccount: withVinculedAccount,
        includeMenus: true,
      );

      final response = await GetUsersByRolesUseCase().execute(params);
      lastUsersByRolesResponse = response;
      usersByRolesList.addAll(response.users);

      _isLoadingUsersByRoles = false;
      update();
      return usersByRolesList;
    } on ApiException catch (e) {
      _isLoadingUsersByRoles = false;
      update();
      if (e.statusCode == 404) {
        usersByRolesList.clear();
        return null;
      }
      return null;
    } catch (e) {
      _isLoadingUsersByRoles = false;
      rethrow;
    }
  }
}
