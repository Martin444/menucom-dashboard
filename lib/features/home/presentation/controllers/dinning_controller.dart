import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickmeup_dashboard/core/exceptions/api_exception.dart';
import 'package:pickmeup_dashboard/features/home/data/usescases/get_dinning_usescases.dart';
import 'package:pickmeup_dashboard/features/home/data/usescases/get_menu_dinning.dart';
import 'package:pickmeup_dashboard/features/home/data/usescases/post_menu_item_usescases.dart';
import 'package:pickmeup_dashboard/features/home/data/usescases/upload_file_usescases.dart';
import 'package:pickmeup_dashboard/features/home/models/dinning_model.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config.dart';
import '../../data/usescases/put_menu_item_usescases.dart';
import '../../models/menu_item_model.dart';
import '../../models/menu_model.dart';

class DinningController extends GetxController {
  DinningModel dinningLogin = DinningModel();

  void getMyDinningInfo() async {
    try {
      var respDinning = await GetDinningUseCase().execute();
      dinningLogin = respDinning;
      update();
      menusToEdit = await getmenuByDining();
      setDataToEditItem(menusToEdit);
      update();
    } catch (e) {
      rethrow;
    }
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
    menusToEdit = menu;
    if (Get.width < 700) {
      Get.back();
    }
    update();
  }

  bool isEditProcess = false;

  void editItemMenu() async {
    try {
      isEditProcess = true;
      update();
      var newItem = MenuItemModel(
        id: menusToEdit.id,
        name: nameController.text,
        photoUrl: photoController,
        deliveryTime: int.tryParse(deliveryController.text),
        price: int.tryParse(priceController.text),
      );
      await PutMenuItemUsesCases().execute(
        newItem,
      );
      isEditProcess = false;

      await getmenuByDining();
      update();
      var detectItem = menusList.first.items!
          .where((item) => item.id == menusToEdit.id)
          .toList();
      setDataToEditItem(detectItem.first);
    } catch (e) {
      setDataToEditItem(menusToEdit);
    }
  }

  Future<MenuItemModel> getmenuByDining() async {
    try {
      var respMenu = await GetMenuUseCase().execute(dinningLogin.id!);
      menusList.assignAll(respMenu);
      var firstMenuItem = menusList.first.items!.first;
      update();
      return firstMenuItem;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        Get.toNamed(PURoutes.REGISTER_ITEM_MENU);
      }
      rethrow;
    }
  }

  TextEditingController newNameController = TextEditingController();
  TextEditingController newpriceController = TextEditingController();
  TextEditingController newdeliveryController = TextEditingController();
  String newphotoController = '';

  Uint8List? fileTaked;
  Uint8List toSend = Uint8List(1);

  void pickImageDirectory() async {
    final ImagePicker pickerImage = ImagePicker();

    final result = await pickerImage.pickImage(source: ImageSource.gallery);

    if (result != null) {
      Uint8List newFile = await result.readAsBytes();
      toSend = newFile;
      // Upload file
      fileTaked = await result.readAsBytes();
      update();
    }
  }

  bool isLoadMenuItem = false;

  void createMenuItemInServer() async {
    // Primero obtenemos el link de la imagen
    isLoadMenuItem = true;
    update();

    newphotoController = await uploadImage(toSend);
    await createItem();

    isLoadMenuItem = false;
    update();
  }

  Future<String> uploadImage(Uint8List file) async {
    try {
      var responUrl = await UploadFileUsesCase().execute(file);
      return responUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createItem() async {
    try {
      var newItem = MenuItemModel(
        name: newNameController.text,
        photoUrl: newphotoController,
        deliveryTime: int.tryParse(newdeliveryController.text),
        price: int.tryParse(newpriceController.text),
      );

      await PostMenuItemUsesCases().execute(
        menusList.isEmpty ? '' : menusList[0].id ?? '',
        newItem,
      );

      Get.toNamed(PURoutes.HOME);
      newNameController.clear();
      newphotoController = '';
      toSend = Uint8List(1);
      fileTaked = null;
      newdeliveryController.clear();
      newpriceController.clear();
      return;
    } catch (e) {
      rethrow;
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  void closeSesion() async {
    var sesion = await _prefs;
    await sesion.clear();
    ACCESS_TOKEN = '';
    Get.toNamed(PURoutes.LOGIN);
    update();
  }
}
