import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/features/home/data/usescases/upload_file_usescases.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/delete_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/post_ward_item_usescases.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/post_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/usecases/put_wardrobe_usecase.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/clothing_item_model.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class WardrobesController extends GetxController {
  bool isLoadWard = false;
  TextEditingController nameWard = TextEditingController();

  Future<void> postWardrobe() async {
    try {
      isLoadWard = true;
      update();
      final response = await PostWardrobeUsecase.execute(
        PostWardParams(
          description: nameWard.text,
        ),
      );
      print(response);
      isLoadWard = false;
      update();
    } catch (e) {
      throw e;
    }
  }

  WardrobeModel wardSelected = WardrobeModel(
    id: '',
    idOwner: '',
    items: [],
  );

  void gotoEditWardrobe(WardrobeModel select) {
    wardSelected = select;
    nameWard.text = wardSelected.description!;
    update();
    Get.toNamed(PURoutes.EDIT_WARDROBES);
  }

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

  void editWardrobe() async {
    try {
      isLoadWard = true;
      update();
      final response = await PutWardrobeUsecase.execute(
        PostWardParams(
          id: wardSelected.id,
          description: nameWard.text,
        ),
      );
      print(response);
      isLoadWard = false;
      update();
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> deleteWardrobe(WardrobeModel select) async {
    try {
      var isComfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar el guardarropas?',
        message: 'Todos los productos cargados en él se eliminarán',
      );

      if (isComfirm) {
        isLoadWard = true;
        update();
        await DeleteWardrobeUsecase.execute(
          PostWardParams(
            id: select.id,
            description: nameWard.text,
          ),
        );
        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${select.description} con éxito.',
        );
        isLoadWard = false;
        update();
      }
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo eliminar ${select.description}, vuelve a intentarlo mas tarde.',
      );
      throw e;
    }
  }

  // ITEMS WARDROBES

  TextEditingController nameWardController = TextEditingController();
  TextEditingController brandWardController = TextEditingController();
  TextEditingController priceWardController = TextEditingController();
  TextEditingController stockWardController = TextEditingController();
  TextEditingController sizedWardController = TextEditingController();
  List<String> sizesTags = [];
  String newphotoController = '';

  void updateIngredientsSelected({required List<String> tags}) {
    sizesTags = tags;
    update();
  }

  bool isLoadMenuItem = false;

  Future<ClothingItemModel?> createWardItemInServer() async {
    // Primero obtenemos el link de la imagen
    try {
      isLoadMenuItem = true;
      update();

      newphotoController = await uploadImage(toSend);
      var newItemMenu = await createItem();

      isLoadMenuItem = false;
      update();
      return newItemMenu;
    } catch (e) {
      isLoadMenuItem = false;
      update();
      rethrow;
    }
  }

  Future<String> uploadImage(Uint8List file) async {
    try {
      var responUrl = await UploadFileUsesCase().execute(file);
      return responUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<ClothingItemModel> createItem() async {
    try {
      var newItem = ClothingItemModel(
        name: nameWardController.text,
        brand: brandWardController.text,
        photoURL: newphotoController,
        quantity: int.tryParse(stockWardController.text) ?? 1,
        sizes: sizesTags,
        price: double.tryParse(priceWardController.text),
      );

      var respItem = await PostWardItemUsesCases().execute(
        wardSelected.id!,
        newItem,
      );

      GlobalDialogsHandles.snackbarSuccess(
        title: 'Genial',
        message: '${newItem.name} cargado con éxito!',
      );
      nameWardController.clear();
      newphotoController = '';
      toSend = Uint8List(1);
      fileTaked = null;
      brandWardController.clear();
      priceWardController.clear();
      stockWardController.clear();
      print(respItem);
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
