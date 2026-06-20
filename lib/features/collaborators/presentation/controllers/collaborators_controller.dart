import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user_roles/assign_role/data/usecase/assign_role_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/assign_role/model/assign_role.dart';
import 'package:menu_dart_api/by_feature/user_roles/revoke_role/data/usecase/revoke_role_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/revoke_role/model/revoke_role_request.dart';
import 'package:menu_dart_api/by_feature/user_roles/update_role/data/usecase/update_role_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/update_role/model/update_role_request.dart';
import 'package:menu_dart_api/by_feature/user_roles/my_team/data/usecase/get_my_team_usecase.dart';
import 'package:menu_dart_api/by_feature/user_roles/my_team/model/my_team_response.dart';

class CollaboratorsController extends GetxController {
  final GetMyTeamUseCase _getMyTeamUseCase;
  final AssignRoleUseCase _assignRoleUseCase;
  final RevokeRoleUseCase _revokeRoleUseCase;
  final UpdateRoleUseCase _updateRoleUseCase;
  final String _businessContext;
  String _commerceId;

  final teamUsers = <TeamUser>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final currentPage = 1.obs;
  final searchController = TextEditingController();
  static const _pageSize = 20;

  CollaboratorsController({
    required GetMyTeamUseCase getMyTeamUseCase,
    required AssignRoleUseCase assignRoleUseCase,
    required RevokeRoleUseCase revokeRoleUseCase,
    required UpdateRoleUseCase updateRoleUseCase,
    required String commerceId,
    required String businessContext,
  })  : _getMyTeamUseCase = getMyTeamUseCase,
        _assignRoleUseCase = assignRoleUseCase,
        _revokeRoleUseCase = revokeRoleUseCase,
        _updateRoleUseCase = updateRoleUseCase,
        _commerceId = commerceId,
        _businessContext = businessContext;

  List<TeamUser> get filteredUsers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return teamUsers;
    return teamUsers.where((u) {
      return u.name.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
    }).toList();
  }

  int get totalCount => teamUsers.length;

  int get ownerCount =>
      teamUsers.where((u) => u.roles.any((r) => r.role == 'owner')).length;

  int get managerCount =>
      teamUsers.where((u) => u.roles.any((r) => r.role == 'manager')).length;

  int get staffCount =>
      teamUsers.where((u) => u.roles.any((r) => r.role == 'operator')).length;

  String _mapRoleToBackend(String uiRole) {
    switch (uiRole) {
      case 'staff':
        return 'operator';
      default:
        return uiRole;
    }
  }

  int get totalPages => (totalCount / _pageSize).ceil().clamp(1, 999);

  List<TeamUser> get paginatedUsers {
    final filtered = filteredUsers;
    if (filtered.isEmpty) return [];
    final start = (currentPage.value - 1) * _pageSize;
    if (start >= filtered.length) {
      currentPage.value = 1;
      return filtered.take(_pageSize).toList();
    }
    final end = start + _pageSize;
    if (end >= filtered.length) return filtered.sublist(start);
    return filtered.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    loadTeam();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadTeam() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _getMyTeamUseCase.execute();
      teamUsers.value = response.users;
      if (response.commerceId.isNotEmpty) {
        _commerceId = response.commerceId;
      }
    } catch (e) {
      errorMessage.value = 'Error al cargar el equipo';
      if (Get.context != null) {
        Get.snackbar('Error', errorMessage.value,
            backgroundColor: const Color(0xFFFFEAEA),
            colorText: const Color(0xFFD32F2F));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> assignRole({
    required String userId,
    required String role,
  }) async {
    try {
      if (_commerceId.isEmpty) {
        return 'No se pudo identificar el comercio. Recargá la página.';
      }

      await _assignRoleUseCase.execute(
        AssignRoleRequest(
          userId: userId,
          role: _mapRoleToBackend(role),
          context: _businessContext,
          resourceId: _commerceId,
        ),
      );
      await loadTeam();
      return null;
    } catch (e) {
      return 'Error al asignar rol: ${e.toString()}';
    }
  }

  Future<String?> changeRole({
    required String userId,
    required String oldRole,
    required String newRole,
  }) async {
    try {
      if (_commerceId.isEmpty) {
        return 'No se pudo identificar el comercio. Recargá la página.';
      }
      await _revokeRoleUseCase.execute(
        RevokeRoleRequest(
          userId: userId,
          role: _mapRoleToBackend(oldRole),
          context: _businessContext,
          resourceId: _commerceId,
        ),
      );
      await _assignRoleUseCase.execute(
        AssignRoleRequest(
          userId: userId,
          role: _mapRoleToBackend(newRole),
          context: _businessContext,
          resourceId: _commerceId,
        ),
      );
      await loadTeam();
      return null;
    } catch (e) {
      return 'Error al cambiar rol: ${e.toString()}';
    }
  }

  Future<String?> removeCollaborator({
    required String userId,
    required String role,
  }) async {
    try {
      if (_commerceId.isEmpty) {
        return 'No se pudo identificar el comercio. Recargá la página.';
      }
      await _revokeRoleUseCase.execute(
        RevokeRoleRequest(
          userId: userId,
          role: _mapRoleToBackend(role),
          context: _businessContext,
          resourceId: _commerceId,
        ),
      );
      await loadTeam();
      return null;
    } catch (e) {
      return 'Error al remover colaborador: ${e.toString()}';
    }
  }

  Future<String?> updateUserRoleStatus({
    required String roleId,
    required bool isActive,
  }) async {
    try {
      await _updateRoleUseCase.execute(
        roleId,
        UpdateRoleRequest(isActive: isActive),
      );
      await loadTeam();
      return null;
    } catch (e) {
      return 'Error al actualizar estado';
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
  }

  void goToPage(int page) {
    currentPage.value = page;
  }

}
