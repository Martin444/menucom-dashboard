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
      final roleByRoleUser = RolesFuncionts.getTypeRoleByRoleString(dinningLogin.role!);
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

      final responseWar = await GetClothingUserUsescase().execute(dinningLogin.id!);
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

  bool _isLoadingWardrobes = false; // Flag para evitar llamadas concurrentes

  void chageWardSelected(WardrobeModel select) {
    wardSelected = select;
    update();
  }

  void chageMenuSelected(MenuModel select) {
    menuSelected = select;
    update();
  }

  MenuItemModel menusToEdit = MenuItemModel();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  String photoController = '';

  Future<List<MenuModel>?> getmenuByDining() async {
    try {
      var respMenu = await GetMenuUseCase().execute(dinningLogin.id!);

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
