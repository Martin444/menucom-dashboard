import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/token_helper.dart';

import '../../../core/navigation/menu_navigation_controller.dart';
import '../../../core/config.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/mixins/navigation_state_mixin.dart';

class DinningController extends GetxController {
  final MPOAuthService _mpService = MPOAuthService();

  /// Hashea el accessToken actual de la sesión
  Future<String> getHashedAccessToken() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    if (token == null || token.isEmpty) return '';
    return hashAccessToken(token);
  }

  DinningModel dinningLogin = DinningModel();

  RxBool isLoadingDataUser = true.obs;
  RxBool hasErrorLoadingUser = false.obs;
  RxBool everyListEmpty = true.obs;
  RxBool isBannerVisible = true.obs;
  RxBool isLinkedToMP = false.obs;
  RxBool isLoadingMPStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBannerVisibility();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMyDinningInfo();
      checkMPStatus();
    });
  }

  Future<void> _loadBannerVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    isBannerVisible.value = prefs.getBool('mp_banner_visible') ?? true;
  }

  Future<void> setBannerVisible(bool visible) async {
    isBannerVisible.value = visible;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mp_banner_visible', visible);
  }

  void getMyDinningInfo() async {
    try {
      isLoadingDataUser.value = true;
      hasErrorLoadingUser.value = false;

      // Asegurar que el token esté configurado si por alguna razón se perdió
      if (API.loginAccessToken.isEmpty) {
        final storage = const FlutterSecureStorage();
        final savedToken = await storage.read(key: 'access_token');
        if (savedToken != null && savedToken.isNotEmpty) {
          API.setAccessToken(savedToken);
          debugPrint('DinningController: Token recuperado desde storage');
        }
      }

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
        case RolesUsers.event_organizer:
          // Los organizadores de eventos no usan catálogos tradicionales
          everyListEmpty.value = true;
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
      hasErrorLoadingUser.value = true;
      isLoadingDataUser.value = false;
      update();
    }
  }

  /// Verifica si la cuenta está vinculada a Mercado Pago
  Future<void> checkMPStatus() async {
    try {
      isLoadingMPStatus.value = true;
      final linked = await _mpService.isAccountLinked();
      isLinkedToMP.value = linked;
      debugPrint('DinningController: MP Linked Status: $linked');
    } catch (e) {
      debugPrint('Error checking MP status: $e');
    } finally {
      isLoadingMPStatus.value = false;
      update();
    }
  }

  /// Inicia el flujo de vinculación con Mercado Pago
  Future<void> vincularMercadoPago() async {
    try {
      final redirectUri = Config.mpRedirectUri;
      final result = await _mpService.initiateLinkingFlow(redirectUri);

      if (result.hasAuthUrl) {
        final uri = Uri.parse(result.authUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'No se pudo abrir el navegador para la vinculación',
            backgroundColor: const Color(0xFFFFEAEA),
            colorText: const Color(0xFFD32F2F),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (result.isAlreadyLinked) {
        isLinkedToMP.value = true;
        update();
        Get.snackbar(
          'Aviso',
          'Tu cuenta ya se encuentra vinculada',
          backgroundColor: const Color(0xFFE8F5E9),
          colorText: const Color(0xFF2E7D32),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error initiating MP linking: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado al iniciar la vinculación',
        backgroundColor: const Color(0xFFFFEAEA),
        colorText: const Color(0xFFD32F2F),
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F)),
      );
    }
  }

  /// Actualiza manualmente el estado de Mercado Pago
  Future<void> refreshMPStatus() async {
    await checkMPStatus();
    if (isLinkedToMP.value) {
      Get.snackbar(
        'Sincronizado',
        'El estado de Mercado Pago se actualizó correctamente',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF2E7D32)),
      );
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

      for (var e in response) {
        catalogsList.add(e);
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

  void clearData() {
    dinningLogin = DinningModel();
    catalogsList.clear();
    catalogSelected = null;
    usersByRolesList.clear();
    everyListEmpty.value = true;
    update();
  }

  void closeSesion() async {
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    } else {
      clearData();
      final storage = const FlutterSecureStorage();
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'authenticated_user');
      API.setAccessToken('');
      Get.offAllNamed(PURoutes.LOGIN);
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Sincronizar el estado de navegación cuando el controlador esté listo
    syncNavigationState();
  }
}
