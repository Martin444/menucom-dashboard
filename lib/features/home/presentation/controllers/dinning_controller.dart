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
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/get_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config.dart';
import '../../data/usescases/put_menu_item_usescases.dart';
import '../../models/menu_item_model.dart';
import '../../models/menu_model.dart';

class DinningController extends GetxController {
  DinningModel dinningLogin = DinningModel();

  bool isLoaginDataUser = false;

  void getMyDinningInfo() async {
    try {
      isLoaginDataUser = true;
      update();
      var respDinning = await GetDinningUseCase().execute();
      dinningLogin = respDinning;
      if (dinningLogin.role == "dining") {
        await getmenuByDining();
      } else {
        await getWardrobebyDining();
      }
      isLoaginDataUser = false;
      update();
      // setDataToEditItem(menusToEdit);
      update();
    } catch (e) {
      isLoaginDataUser = false;
      update();
      rethrow;
    }
  }

  Future<List<WardrobeModel>?> getWardrobebyDining() async {
    try {
      wardList = [];
      final responseWar = await GetWardrobeUsecase.execute();
      for (var e in responseWar) {
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
      var detectItem = menusList.first.items!.where((item) => item.id == menusToEdit.id).toList();
      setDataToEditItem(detectItem.first);
    } catch (e) {
      setDataToEditItem(menusToEdit);
    }
  }

  Future<List<MenuModel>?> getmenuByDining() async {
    try {
      var respMenu = await GetMenuUseCase().execute(dinningLogin.id!);

      menusList.assignAll(respMenu);
      menuSelected = menusList.first;
      everyListEmpty = true;
      update();
      return menusList;
    } on ApiException catch (e) {
      update();
      if (e.statusCode == 404) {
        everyListEmpty = false;
        return null;
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
    Get.offAllNamed(PURoutes.LOGIN);
    update();
  }
}
