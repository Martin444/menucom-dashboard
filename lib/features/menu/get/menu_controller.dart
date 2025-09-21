import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/core/functions/mc_functions.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

import '../../../core/handles/global_handle_dialogs.dart';
import '../../../core/helpers/image_size_helper.dart';

class MenusController extends GetxController {
  TextEditingController nameMenu = TextEditingController();
  MenuModel menuSelected = MenuModel();

  bool isLoadMenus = false;

  Future<void> postNewMenu() async {
    try {
      isLoadMenus = true;
      update();
      var responseMenu = await PostMenuUsecase.execute(MenuParams(
        description: nameMenu.text,
      ));

      isLoadMenus = false;
      update();
      return responseMenu;
    } catch (e) {
      isLoadMenus = false;
      update();
      rethrow;
    }
  }

  void gotoEditMenu(MenuModel select) {
    menuSelected = select;
    nameMenu.text = menuSelected.description!;
    update();
    Get.toNamed(PURoutes.EDIT_MENU_CATEGORY);
  }

  Future<dynamic> editMenu() async {
    try {
      isLoadMenus = true;
      update();
      final response = await PutMenuUsecase.execute(
        MenuParams(
          id: menuSelected.id,
          description: nameMenu.text,
        ),
      );
      isLoadMenus = false;
      update();
      return response;
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo editar ${menuSelected.description}, vuelve a intentarlo mas tarde.',
      );
    }
  }

  Future<dynamic> deleteMenus(MenuModel select) async {
    try {
      var isComfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar este menú?',
        message: 'Todos los platos cargados en él se eliminarán',
      );

      if (isComfirm) {
        isLoadMenus = true;
        update();
        await DeleteMenuUsecase.execute(
          MenuParams(
            id: select.id,
            description: nameMenu.text,
          ),
        );
        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${select.description} con éxito.',
        );
        isLoadMenus = false;
        update();
      }
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo eliminar ${select.description}, vuelve a intentarlo mas tarde.',
      );
    }
  }

  // ITEMS DE LOS MENUS
  TextEditingController newNameController = TextEditingController();
  TextEditingController newpriceController = TextEditingController();
  TextEditingController newdeliveryController = TextEditingController();
  TextEditingController tagIngredientsController = TextEditingController();
  List<String> ingredientsTags = [];
  String newphotoController = '';
  MenuItemModel menuItemToEdit = MenuItemModel();

  Uint8List? fileTaked;
  Uint8List toSend = Uint8List(1);

  void gotoEditItemMenu(MenuItemModel menu) async {
    try {
      newNameController.text = menu.name!;
      newpriceController.text = menu.price!.toString();
      newdeliveryController.text = menu.deliveryTime!.toString();
      newphotoController = menu.photoUrl!;
      ingredientsTags = menu.ingredients!;
      menuItemToEdit = menu;
      var resultIamge = await McFunctions().fetchImageAsUint8List(newphotoController);
      fileTaked = resultIamge;
      toSend = fileTaked!;
      update();
      Get.toNamed(PURoutes.EDIT_ITEM_MENU);
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo completar la acción, $e.',
      );
    }
  }

  bool isEditProcess = false;

  Future<void> editItemMenu() async {
    try {
      isEditProcess = true;
      update();
      newphotoController = await uploadImage(toSend);
      var newItem = MenuItemModel(
        id: menuItemToEdit.id,
        name: newNameController.text,
        photoUrl: newphotoController,
        deliveryTime: int.tryParse(newdeliveryController.text),
        ingredients: ingredientsTags,
        price: int.tryParse(newpriceController.text),
      );
      await PutMenuItemUsesCases().execute(
        newItem,
      );
      isEditProcess = false;
      update();
    } catch (e) {
      isEditProcess = false;
      update();
      rethrow;
    }
  }

  Future<void> deleteItemMenu(MenuItemModel menuItem) async {
    try {
      var isComfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar ${menuItem.name}?',
        // message: '',
      );
      if (isComfirm) {
        await DeleteMenuItemUsesCases().execute(menuItem);
        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${menuItem.name} con éxito.',
        );
      }
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo eliminar ${menuItem.name}, vuelve a intentarlo mas tarde.',
      );
    }
  }

  void updateIngredientsSelected({required List<String> tags}) {
    ingredientsTags = tags;
    update();
  }

  void pickImageDirectory() async {
    final ImagePicker pickerImage = ImagePicker();
    final result = await pickerImage.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final String? extension = result.name.split('.').last.toLowerCase();
      if (extension != 'png' && extension != 'jpg' && extension != 'jpeg') {
        Get.snackbar(
          'Formato inválido',
          'Solo se permiten imágenes PNG o JPG.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      Uint8List originalFile = await result.readAsBytes();
      // Reducir imagen si es necesario
      Uint8List reducedFile = ImageSizeHelper.resizeIfNeeded(originalFile);
      toSend = reducedFile;
      fileTaked = reducedFile;
      update();
    }
  }

  bool isLoadMenuItem = false;

  Future<MenuItemModel> createMenuItemInServer() async {
    // Primero obtenemos el link de la imagen
    isLoadMenuItem = true;
    update();

    newphotoController = await uploadImage(toSend);
    var newItemMenu = await createItem();

    isLoadMenuItem = false;
    update();
    return newItemMenu;
  }

  Future<String> uploadImage(Uint8List file) async {
    try {
      var responUrl = await UploadFileUsesCase().execute(file);
      return responUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<MenuItemModel> createItem() async {
    try {
      var newItem = MenuItemModel(
        name: newNameController.text,
        photoUrl: newphotoController,
        deliveryTime: int.tryParse(newdeliveryController.text),
        ingredients: ingredientsTags,
        price: int.tryParse(newpriceController.text),
      );

      var respItem = await PostMenuItemUsesCases().execute(
        menuSelected.id!,
        newItem,
      );

      GlobalDialogsHandles.snackbarSuccess(
        title: 'Genial',
        message: '${newItem.name} cargado con éxito!',
      );
      newNameController.clear();
      newphotoController = '';
      toSend = Uint8List(1);
      fileTaked = null;
      newdeliveryController.clear();
      newpriceController.clear();
      return respItem;
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: 'Ups no se pudo cargar al menu',
        message: '$e',
      );
      rethrow;
    }
  }
}
