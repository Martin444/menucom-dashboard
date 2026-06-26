import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/controllers/user_session_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/mp_link_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/form_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/user_role_service.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class DinningController extends GetxController {
  UserSessionController get _session => Get.find<UserSessionController>();
  MPLinkController get _mpLink => Get.find<MPLinkController>();
  CatalogsController get _catalogs => Get.find<CatalogsController>();
  FormController get _form => Get.find<FormController>();
  UserRoleService get _roleService => Get.find<UserRoleService>();

  // ─── User session ───
  DinningModel get dinningLogin => _session.dinningLogin;
  set dinningLogin(DinningModel v) => _session.dinningLogin = v;
  RxBool get isLoadingDataUser => _session.isLoadingDataUser;
  RxBool get hasErrorLoadingUser => _session.hasErrorLoadingUser;
  RxBool get everyListEmpty => _session.everyListEmpty;
  RxBool get hasMissingLogo => _session.hasMissingLogo;
  RxBool get hasSelectedCommerce => _session.hasSelectedCommerce;
  RxString get currentUserRole => _session.currentUserRole;
  RxString get currentContextType => _session.currentContextType;
  bool get isCustomerRole => _session.isCustomerRole;

  Future<String> getHashedAccessToken() => _session.getHashedAccessToken();
  void getMyDinningInfo() => _session.getMyDinningInfo();
  void clearData() {
    _session.clearData();
    _catalogs.catalogsList.clear();
    _catalogs.catalogSelected.value = null;
  }
  void closeSesion() => _session.closeSesion();

  // ─── MP Link ───
  RxBool get isLinkedToMP => _mpLink.isLinkedToMP;
  RxBool get isLoadingMPStatus => _mpLink.isLoadingMPStatus;
  RxBool get isBannerVisible => _mpLink.isBannerVisible;

  Future<void> setBannerVisible(bool v) => _mpLink.setBannerVisible(v);
  Future<void> checkMPStatus() => _mpLink.checkMPStatus();
  Future<void> vincularMercadoPago() => _mpLink.vincularMercadoPago();
  Future<void> refreshMPStatus() => _mpLink.refreshMPStatus();

  // ─── Catalog selection ───
  List<CatalogModel> get catalogsList => _catalogs.catalogsList;
  List<CatalogModel> get unlinkedCatalogsList => _catalogs.unlinkedCatalogs;
  CatalogModel? get catalogSelected => _catalogs.catalogSelected.value;
  List<CatalogModel> get wardList => _catalogs.catalogsList;
  CatalogModel? get wardSelected => _catalogs.catalogSelected.value;
  List<CatalogModel> get menusList => _catalogs.catalogsList;
  CatalogModel? get menuSelected => _catalogs.catalogSelected.value;

  void chageCatalogSelected(CatalogModel s) {
    _catalogs.catalogSelected.value = s;
    _catalogs.update();
  }

  List<UserByRoleModel> get usersByRolesList => _session.usersByRolesList;
  UsersByRolesResponse? get lastUsersByRolesResponse => _session.lastUsersByRolesResponse;
  bool get isLoadingUsersByRoles => _session.isLoadingUsersByRoles;
  Future<List<UserByRoleModel>?> getUsersByRoles({
    required List<RolesUsers> roles,
    bool withVinculedAccount = false,
  }) => _session.getUsersByRoles(roles: roles, withVinculedAccount: withVinculedAccount);

  // ─── Form ───
  CatalogItemModel get menusToEdit => _form.menusToEdit;
  set menusToEdit(CatalogItemModel v) => _form.menusToEdit = v;
  TextEditingController get nameController => _form.nameController;
  TextEditingController get priceController => _form.priceController;
  TextEditingController get deliveryController => _form.deliveryController;
  String get photoController => _form.photoController;
  set photoController(String v) => _form.photoController = v;

  // ─── Lifecycle ───
  bool _started = false;

  void _redirectByRoleIfNeeded() {
    if (!Get.isRegistered<AuthController>() || 
        !Get.find<AuthController>().isAuthenticated) {
      return;
    }
    final role = RolesFuncionts.getTypeRoleByRoleString(
      _session.dinningLogin.role ?? '',
    );
    if (role == RolesUsers.admin) {
      Get.offAllNamed(PURoutes.ADMIN_DASHBOARD);
    } else if (role == RolesUsers.event_organizer) {
      Get.offAllNamed(PURoutes.EVENTS);
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (_started) return;
    _started = true;

    final auth = Get.find<AuthController>();
    if (!auth.isAuthenticated) return;

    ever(_session.isLoadingDataUser, (_) => update());
    ever(_session.hasErrorLoadingUser, (_) => update());
    ever(_session.hasSelectedCommerce, (_) => update());
    ever(_session.hasMissingLogo, (_) => update());
    ever(_session.currentUserRole, (_) {
      _roleService.updateRole(_session.currentUserRole.value);
      _redirectByRoleIfNeeded();
      update();
    });
    ever(_session.everyListEmpty, (_) => update());
    ever(_mpLink.isLinkedToMP, (_) => update());
    ever(_mpLink.isBannerVisible, (_) => update());
    ever(_mpLink.isLoadingMPStatus, (_) => update());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!auth.isAuthenticated) return;
      _session.getMyDinningInfo();
      _mpLink.checkMPStatus();
    });
  }
}