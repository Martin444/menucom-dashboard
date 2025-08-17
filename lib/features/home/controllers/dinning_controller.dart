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
    try {
      wardList = [];
      final responseWar = await GetClothingUserUsescase().execute(dinningLogin.id!);
      for (var e in responseWar.listClothing!) {
        wardList.add(e);
      }
      wardSelected = wardList.first;
      update();
      return wardList;
    } on ApiException catch (e) {
      everyListEmpty = false;
      update();
      if (e.statusCode == 404) {
        return null;
      }
      return null;
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
