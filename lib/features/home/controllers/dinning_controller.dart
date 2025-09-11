import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config.dart';
import '../../../core/mixins/navigation_state_mixin.dart';

class DinningController extends GetxController with NavigationStateMixin {
  DinningModel dinningLogin = DinningModel();

  bool isLoaginDataUser = false;

  @override
  void onInit() {
    super.onInit();
    getMyDinningInfo();
  }

  void getMyDinningInfo() async {
    try {
      isLoaginDataUser = true;
      // update();
      var respDinning = await GetDinningUseCase().execute();
      dinningLogin = respDinning;

      // Verificar que el rol no sea null antes de procesarlo
      final userRole = dinningLogin.role;
      if (userRole == null || userRole.isEmpty) {
        throw Exception('Rol de usuario no válido');
      }

      final roleByRoleUser = RolesFuncionts.getTypeRoleByRoleString(userRole);
      switch (roleByRoleUser) {
        case RolesUsers.dinning:
          await getmenuByDining();
          break;
        case RolesUsers.clothes:
          await getWardrobebyDining();
          break;
        default:
        // closeSesion();
      }

      isLoaginDataUser = false;
      update();
      // setDataToEditItem(menusToEdit);
      update();
    } catch (e) {
      closeSesion();
      isLoaginDataUser = false;
      // update();
    }
  }

  //Wardrobes

  Future<List<WardrobeModel>?> getWardrobebyDining() async {
    if (_isLoadingWardrobes) {
      debugPrint('=== getWardrobebyDining already in progress, skipping ===');
      return wardList;
    }

    try {
      _isLoadingWardrobes = true;
      debugPrint('=== DEBUG getWardrobebyDining CALLED ===');
      debugPrint('Current wardList length before clear: ${wardList.length}');
      wardList = [];
      debugPrint('wardList cleared, length: ${wardList.length}');

      final userId = dinningLogin.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('ID de usuario no válido');
      }

      final responseWar = await GetClothingUserUsescase().execute(userId);
      debugPrint('=== DEBUG DinningController.getWardrobebyDining ===');
      debugPrint('API response wardrobes count: ${responseWar.listClothing?.length ?? 0}');

      // Debug: Verificar cada elemento de la respuesta
      if (responseWar.listClothing != null) {
        for (int i = 0; i < responseWar.listClothing!.length; i++) {
          debugPrint(
              'API Response Item $i: ${responseWar.listClothing![i].description} (ID: ${responseWar.listClothing![i].id})');
        }
      }

      for (var e in responseWar.listClothing!) {
        debugPrint('Adding wardrobe: ${e.description} (ID: ${e.id})');
        wardList.add(e);
        debugPrint('wardList length after adding: ${wardList.length}');
      }

      debugPrint('Final wardList length: ${wardList.length}');
      wardSelected = wardList.first;
      debugPrint('Selected wardrobe: ${wardSelected.description}');
      update();
      _isLoadingWardrobes = false;
      return wardList;
    } on ApiException catch (e) {
      _isLoadingWardrobes = false;
      everyListEmpty = false;
      update();
      if (e.statusCode == 404) {
        return null;
      }
      return null;
    } catch (e) {
      _isLoadingWardrobes = false;
      rethrow;
    }
  }

  List<MenuModel> menusList = <MenuModel>[];
  MenuModel menuSelected = MenuModel();
  bool everyListEmpty = true;
  List<WardrobeModel> wardList = <WardrobeModel>[];
  WardrobeModel wardSelected = WardrobeModel(
    id: '',
    idOwner: '',
    items: [],
  );

  // Variables para el manejo de usuarios por roles
  List<UserByRoleModel> usersByRolesList = <UserByRoleModel>[];
  bool _isLoadingUsersByRoles = false;
  UsersByRolesResponse? lastUsersByRolesResponse;

  // Getter público para el estado de carga de usuarios por roles
  bool get isLoadingUsersByRoles => _isLoadingUsersByRoles;

  bool _isLoadingWardrobes = false; // Flag para evitar llamadas concurrentes

  void chageWardSelected(WardrobeModel select) {
    wardSelected = select;
    update();
  }

  void chageMenuSelected(MenuModel select) {
    menuSelected = select;
    update();
  }

  /// Obtiene usuarios filtrados por roles específicos
  ///
  /// [roles] - Lista de roles para filtrar usuarios
  /// [withVinculedAccount] - Incluir información de cuentas vinculadas
  ///
  /// Retorna la lista de usuarios encontrados o null si hay error
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
      debugPrint('=== DEBUG getUsersByRoles CALLED ===');
      debugPrint('Roles requested: ${roles.map((r) => r.toString().split('.').last).join(', ')}');
      debugPrint('With vinculated account: $withVinculedAccount');

      // Limpiar lista anterior
      usersByRolesList.clear();

      // Crear parámetros para la consulta
      final params = UsersByRolesParams(
        roles: roles,
        withVinculedAccount: withVinculedAccount,
        includeMenus: true,
      );

      // Ejecutar el caso de uso
      final response = await GetUsersByRolesUseCase().execute(params);
      lastUsersByRolesResponse = response;

      debugPrint('=== DEBUG DinningController.getUsersByRoles ===');
      debugPrint('API response users count: ${response.total}');

      // Debug: Verificar cada elemento de la respuesta
      for (int i = 0; i < response.users.length; i++) {
        final user = response.users[i];
        debugPrint('=== USER $i DETAILS ===');
        debugPrint('Name: ${user.name}');
        debugPrint('Role: ${user.role}');
        debugPrint('Email: ${user.email}');
        debugPrint('Phone: ${user.phone}');
        debugPrint('PhotoURL: ${user.photoURL}');
        debugPrint('IsEmailVerified: ${user.isEmailVerified}');
        debugPrint('CreateAt: ${user.createAt}');
        debugPrint('LastLoginAt: ${user.lastLoginAt}');
        debugPrint('ID: ${user.id}');
        debugPrint('====================');
      }

      // Agregar usuarios a la lista
      usersByRolesList.addAll(response.users);

      debugPrint('Final usersByRolesList length: ${usersByRolesList.length}');

      _isLoadingUsersByRoles = false;
      update();
      return usersByRolesList;
    } on ApiException catch (e) {
      _isLoadingUsersByRoles = false;
      debugPrint('Error getting users by roles: ${e.statusCode} - ${e.message}');
      update();

      if (e.statusCode == 404) {
        usersByRolesList.clear();
        return null;
      }
      return null;
    } catch (e) {
      _isLoadingUsersByRoles = false;
      debugPrint('Unexpected error getting users by roles: $e');
      rethrow;
    }
  }

  MenuItemModel menusToEdit = MenuItemModel();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  String photoController = '';

  Future<List<MenuModel>?> getmenuByDining() async {
    try {
      final userId = dinningLogin.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('ID de usuario no válido');
      }

      var respMenu = await GetMenuUseCase().execute(userId);

      menusList.assignAll(respMenu.listmenus!);
      menuSelected = menusList.first;
      everyListEmpty = true;
      update();
      return menusList;
    } on ApiException catch (e) {
      update();
      if (e.statusCode == 404) {
        everyListEmpty = false;
        menusList.clear();

        update();
        return null;
      }
      rethrow;
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void closeSesion() async {
    var sesion = await _prefs;
    await sesion.clear();
    ACCESS_TOKEN = '';
    Get.offAllNamed(PURoutes.LOGIN);
    update();
  }

  @override
  void onReady() {
    super.onReady();
    // Sincronizar el estado de navegación cuando el controlador esté listo
    syncNavigationState();
  }
}
