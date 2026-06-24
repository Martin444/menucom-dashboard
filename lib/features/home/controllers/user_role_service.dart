import 'package:get/get.dart';

class UserRoleService extends GetxController {
  String _currentRole = '';

  String get currentRole => _currentRole;

  bool get _isAdminOrOwner =>
      _currentRole == 'admin' || _currentRole == 'owner';
  bool get _isAdminOrOwnerOrManager =>
      _isAdminOrOwner || _currentRole == 'manager';

  // ─── Catalog permissions ───
  bool get canCreateCatalog => _isAdminOrOwner;
  bool get canUpdateCatalog => _isAdminOrOwnerOrManager;
  bool get canDeleteCatalog => _isAdminOrOwner;

  // ─── Item permissions ───
  bool get canCreateItem => _isAdminOrOwnerOrManager;
  bool get canUpdateItem => _isAdminOrOwnerOrManager;
  bool get canDeleteItem => _isAdminOrOwnerOrManager;

  void updateRole(String role) {
    final normalized = role.toLowerCase().trim();
    if (_currentRole != normalized) {
      _currentRole = normalized;
      update();
    }
  }
}
