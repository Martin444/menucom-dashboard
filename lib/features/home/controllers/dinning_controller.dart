import '../../../helpers/token_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/navigation/menu_navigation_controller.dart';
import '../../../core/config.dart';
import '../../../core/mixins/navigation_state_mixin.dart';

class DinningController extends GetxController with NavigationStateMixin {
  /// Hashea el accessToken actual de la sesión
  String getHashedAccessToken() {
    debugPrint("Access Token: $ACCESS_TOKEN");
    var hashed = hashAccessToken(ACCESS_TOKEN);
    debugPrint("Hashed Access Token: $hashed");
    return hashed;
  }

  DinningModel dinningLogin = DinningModel();

  RxBool isLoadingDataUser = false.obs;
  RxBool everyListEmpty = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMyDinningInfo();
    });
  }

  void getMyDinningInfo() async {
    try {
      isLoadingDataUser.value = true;
      var respDinning = await GetDinningUseCase().execute();
      dinningLogin = respDinning;

      final userRole = dinningLogin.role;
      if (userRole == null || userRole.isEmpty) {
        throw Exception('Rol de usuario no válido');
      }

      // Marcar que ya no está vacío porque tenemos info del usuario
      everyListEmpty.value = false;

      final roleByRoleUser = RolesFuncionts.getTypeRoleByRoleString(userRole);
      switch (roleByRoleUser) {
        case RolesUsers.dinning:
        case RolesUsers.food:
          await getCatalogsByType('menu');
          break;
        case RolesUsers.clothes:
        case RolesUsers.retail:
        case RolesUsers.water_distributor:
        case RolesUsers.grocery:
        case RolesUsers.accessories:
        case RolesUsers.electronics:
        case RolesUsers.pharmacy:
        case RolesUsers.beauty:
        case RolesUsers.construction:
        case RolesUsers.automotive:
        case RolesUsers.pets:
          await getCatalogsByType('wardrobe');
          break;
        default:
      }

      isLoadingDataUser.value = false;
      
      // Notificar cambios para que MenuSide y otros se actualicen
      update();
      
      // Sincronizar navegación después de obtener el rol
      if (Get.isRegistered<MenuNavigationController>()) {
        Get.find<MenuNavigationController>().update();
      }
    } catch (e) {
      debugPrint('Error getting dinning info: $e');
      // No cerrar sesión automáticamente aquí si es solo un error de red o similar
      // closeSesion(); 
      isLoadingDataUser.value = false;
      update();
    }
  }

  // Catalogs (new unified system - replaces Wardrobe/Menu)

  Future<List<CatalogModel>?> getCatalogsByType(String type) async {
    if (_isLoadingWardrobes) {
      debugPrint('=== getCatalogsByType already in progress, skipping ===');
      return catalogsList;
    }

    try {
      _isLoadingWardrobes = true;
      debugPrint('=== DEBUG getCatalogsByType CALLED ===');
      debugPrint('Type: $type');
      debugPrint('Current catalogsList length before clear: ${catalogsList.length}');
      catalogsList.clear();

      final response = await GetMyCatalogsUseCase().execute(type: type);
      debugPrint('=== DEBUG DinningController.getCatalogsByType ===');
      debugPrint('API response catalogs count: ${response.length}');

      for (int i = 0; i < response.length; i++) {
        debugPrint('API Response Item $i: ${response[i].description} (ID: ${response[i].id})');
      }

      for (var e in response) {
        debugPrint('Adding catalog: ${e.description} (ID: ${e.id})');
        catalogsList.add(e);
        debugPrint('catalogsList length after adding: ${catalogsList.length}');
      }

      debugPrint('Final catalogsList length: ${catalogsList.length}');
      catalogSelected = catalogsList.isNotEmpty ? catalogsList.first : null;
      everyListEmpty.value = catalogsList.isEmpty;
      debugPrint('Selected catalog: ${catalogSelected?.description}');
      update();
      _isLoadingWardrobes = false;
      return catalogsList;
    } on ApiException catch (e) {
      _isLoadingWardrobes = false;
      everyListEmpty.value = true;
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

  List<CatalogModel> catalogsList = <CatalogModel>[];
  CatalogModel? catalogSelected;

  // Variables para el manejo de usuarios por roles
  List<UserByRoleModel> usersByRolesList = <UserByRoleModel>[];
  bool _isLoadingUsersByRoles = false;
  UsersByRolesResponse? lastUsersByRolesResponse;

  // Getter público para el estado de carga de usuarios por roles
  bool get isLoadingUsersByRoles => _isLoadingUsersByRoles;

  bool _isLoadingWardrobes = false; // Alias for loading state

  List<CatalogModel> get wardList => catalogsList;
  CatalogModel? get wardSelected => catalogSelected;
  List<CatalogModel> get menusList => catalogsList;
  CatalogModel? get menuSelected => catalogSelected;

  void chageCatalogSelected(CatalogModel select) {
    catalogSelected = select;
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

  CatalogItemModel menusToEdit = CatalogItemModel(
    id: '',
    catalogId: '',
    name: '',
    price: 0.0,
    quantity: 0,
    status: 'available',
    isAvailable: true,
    isFeatured: false,
    displayOrder: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  String photoController = '';

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void closeSesion() async {
    var sesion = await _prefs;
    await sesion.clear();
    ACCESS_TOKEN = '';
    API.setAccessToken('');
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
