import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/data/usescases/get_dinning_usescases.dart';
import 'package:pickmeup_dashboard/features/home/data/usescases/get_menu_dinning.dart';
import 'package:pickmeup_dashboard/features/home/models/dinning_model.dart';
import 'package:pickmeup_dashboard/features/home/models/menu_item_model.dart';
import 'package:pickmeup_dashboard/features/home/models/menu_model.dart';

class DinningController extends GetxController {
  DinningModel dinningLogin = DinningModel();

  void getMyDinningInfo() async {
    try {
      var respDinning = await GetDinningUseCase().execute();
      dinningLogin = respDinning;
      print(respDinning);
      getmenuByDining(dinningLogin.id ?? '');
      update();
    } catch (e) {}
  }

  List<MenuModel> menusList = <MenuModel>[];
  MenuItemModel menusToEdit = MenuItemModel();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  String photoController = '';

  void setDataToEditItem(MenuItemModel menu) {
    nameController.text = menu.name!;
    priceController.text = menu.price!.toString();
    deliveryController.text = menu.deliveryTime!.toString();
    photoController = menu.photoUrl!;
    update();
  }

  void getmenuByDining(String dinnin) async {
    try {
      var respMenu = await GetMenuUseCase().execute(dinnin);
      menusList.assignAll(respMenu);
      menusToEdit = menusList[0].items![0];
      setDataToEditItem(menusToEdit);
      update();
    } catch (e) {}
  }
}
