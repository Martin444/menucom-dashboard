import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickmeup_dashboard/core/functions/mc_functions.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class WardrobesController extends GetxController {
  bool isLoadWard = false;
  TextEditingController nameWard = TextEditingController();

  Future<bool> postWardrobe() async {
    final wardrobeName = nameWard.text.isNotEmpty ? nameWard.text : "El guardarropa";
    try {
      isLoadWard = true;
      update();
      await PostWardrobeUsecase.execute(
        PostWardParams(
          description: nameWard.text,
        ),
      );
      isLoadWard = false;
      update();

      // Mostrar mensaje de éxito
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Guardarropa creado',
        message: '$wardrobeName se creó exitosamente',
      );

      // Limpiar el campo de nombre
      nameWard.clear();
      return true; // Éxito
    } on ApiException catch (apiError) {
      isLoadWard = false;
      update();

      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo crear el guardarropa',
        defaultErrorMessage: 'Error al crear el guardarropa',
      );
      return false; // Error
    } catch (e) {
      isLoadWard = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al crear el guardarropa. Inténtalo de nuevo.',
      );
      return false; // Error
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

  Future<bool> editWardrobe() async {
    final wardrobeName = nameWard.text.isNotEmpty ? nameWard.text : "El guardarropa";
    try {
      isLoadWard = true;
      update();
      await PutWardrobeUsecase.execute(
        PostWardParams(
          id: wardSelected.id,
          description: nameWard.text,
        ),
      );
      isLoadWard = false;
      update();

      // Mostrar mensaje de éxito
      GlobalDialogsHandles.snackbarSuccess(
        title: 'Guardarropa actualizado',
        message: '$wardrobeName se actualizó exitosamente',
      );
      return true; // Éxito
    } on ApiException catch (apiError) {
      isLoadWard = false;
      update();

      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo actualizar el guardarropa',
        defaultErrorMessage: 'Error al actualizar el guardarropa',
      );
      return false; // Error
    } catch (e) {
      isLoadWard = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al actualizar el guardarropa. Inténtalo de nuevo.',
      );
      return false; // Error
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
      rethrow;
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
      fileTaked = null;
      update();
      return newItemMenu;
    } on ApiException catch (apiError) {
      isLoadMenuItem = false;
      update();

      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo crear el producto',
        defaultErrorMessage: 'Error al crear el producto en el guardarropa',
      );
      return null;
    } catch (e) {
      isLoadMenuItem = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al crear el producto. Inténtalo de nuevo.',
      );
      return null;
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
      return respItem;
    } on ApiException catch (apiError) {
      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo cargar el producto',
        defaultErrorMessage: 'Error al cargar el producto al guardarropa',
      );
      rethrow;
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al cargar el producto. Inténtalo de nuevo.',
      );
      rethrow;
    }
  }

  Future<void> deleteItemClothing(ClothingItemModel wardItem) async {
    try {
      var isComfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar ${wardItem.name}?',
        // message: '',
      );
      if (isComfirm) {
        await DeleteClothingItemUsesCases().execute(wardItem);
        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${wardItem.name} con éxito.',
        );
      }
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo eliminar ${wardItem.name}, vuelve a intentarlo mas tarde.',
      );
    }
  }

  //Editar clothing

  ClothingItemModel clothingToEdit = ClothingItemModel();

  Future<void> goToEditClothing(ClothingItemModel wardItem) async {
    try {
      nameWardController.text = wardItem.name ?? '-';
      brandWardController.text = wardItem.brand ?? '-';
      priceWardController.text = wardItem.price?.toString() ?? '-';
      stockWardController.text = wardItem.quantity?.toString() ?? '-';
      sizesTags = wardItem.sizes ?? [];
      clothingToEdit = wardItem;
      newphotoController = wardItem.photoURL!;
      var resultIamge = await McFunctions().fetchImageAsUint8List(newphotoController);
      fileTaked = resultIamge;
      toSend = fileTaked!;
      Get.toNamed(PURoutes.EDIT_ITEM_WARDROBES);
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message: 'No se pudo completar la acción, vuelve a intentarlo mas tarde.',
      );
    }
  }

  Future<bool> editClothingWardrobe() async {
    try {
      isLoadMenuItem = true;
      update();
      newphotoController = await uploadImage(toSend);
      var newItem = ClothingItemModel(
        id: clothingToEdit.id,
        name: nameWardController.text,
        brand: brandWardController.text,
        photoURL: newphotoController,
        quantity: int.tryParse(stockWardController.text) ?? 1,
        sizes: sizesTags,
        price: double.tryParse(priceWardController.text),
      );

      await PutClothingItemUsesCases().execute(newItem);
      isLoadMenuItem = false;
      update();

      // Mostrar mensaje de éxito
      GlobalDialogsHandles.snackbarSuccess(
        title: '¡Perfecto!',
        message: '${nameWardController.text} se actualizó exitosamente',
      );
      return true; // Éxito
    } on ApiException catch (apiError) {
      isLoadMenuItem = false;
      update();

      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo actualizar el producto',
        defaultErrorMessage: 'Error al actualizar el producto en el guardarropa',
      );
      return false; // Error
    } catch (e) {
      isLoadMenuItem = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al actualizar ${nameWardController.text}. Inténtalo de nuevo.',
      );
      return false; // Error
    }
  }

  /// Método helper para manejar errores de API relacionados con límites de plan
  void _handleApiError(
    ApiException apiError, {
    required String defaultErrorTitle,
    required String defaultErrorMessage,
  }) {
    // Extraer el mensaje de error del JSON
    String errorMessage = defaultErrorMessage;
    try {
      final errorJson = jsonDecode(apiError.message);
      final jsonMessage = errorJson['message']?.toString().trim();
      errorMessage = (jsonMessage?.isNotEmpty == true) ? jsonMessage! : defaultErrorMessage;

      // Detectar si es un error de límites de plan
      if (errorMessage.toLowerCase().contains('límites') ||
          errorMessage.toLowerCase().contains('plan free') ||
          errorMessage.toLowerCase().contains('no puedes crear más')) {
        GlobalDialogsHandles.showPlanLimitDialog(
          title: 'Límite del Plan Gratuito',
          message: errorMessage,
          onUpgradePressed: () {
            // TODO: Navegar a la página de actualización del plan
            // Get.toNamed(PURoutes.UPGRADE_PLAN);
            GlobalDialogsHandles.snackbarError(
              title: 'Función en desarrollo',
              message: 'La actualización del plan estará disponible pronto.',
            );
          },
        );
        return;
      }
    } catch (e) {
      // Si no se puede parsear el JSON, usar el mensaje del error original o el por defecto
      final apiMessage = apiError.message.trim();
      errorMessage = apiMessage.isNotEmpty ? apiMessage : defaultErrorMessage;
    }

    // Validar que el mensaje final no esté vacío antes de mostrar el snackbar
    final finalMessage = errorMessage.trim();
    final validMessage = finalMessage.isNotEmpty ? finalMessage : defaultErrorMessage;

    // Mostrar error genérico
    GlobalDialogsHandles.snackbarError(
      title: defaultErrorTitle,
      message: validMessage,
    );
  }
}
