import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/core/functions/mc_functions.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/core/helpers/image_size_helper.dart';

class CatalogsController extends GetxController {
  final RxList<CatalogModel> catalogsList = <CatalogModel>[].obs;
  final Rxn<CatalogModel> catalogSelected = Rxn<CatalogModel>();
  final RxBool isLoadingCatalogs = false.obs;

  static const String typeMenu = 'menu';
  static const String typeWardrobe = 'wardrobe';
  static const String typeService = 'service';

  String _currentType = typeMenu;
  bool _isLoadingCatalogsInternal = false;

  Future<void> loadCatalogsByType(String type) async {
    if (_isLoadingCatalogsInternal) {
      debugPrint('=== loadCatalogsByType already in progress, skipping ===');
      return;
    }

    try {
      _isLoadingCatalogsInternal = true;
      isLoadingCatalogs.value = true;
      _currentType = type;

      debugPrint('=== DEBUG loadCatalogsByType CALLED ===');
      debugPrint('Type: $type');

      catalogsList.clear();

      final response = await GetMyCatalogsUseCase().execute(type: type);

      debugPrint('=== API Response (getMyCatalogs) ===');
      debugPrint('Catalogs count: ${response.length}');

      for (int i = 0; i < response.length; i++) {
        debugPrint(
            'Catalog $i: ${response[i].description} (ID: ${response[i].id}), items: ${response[i].items?.length ?? 0}');
      }

      catalogsList.addAll(response);

      if (catalogsList.isNotEmpty) {
        final selectedCatalog = catalogSelected.value ?? catalogsList.first;
        catalogSelected.value = selectedCatalog;

        // Cargar los items del catálogo seleccionado usando getCatalogById
        try {
          final fullCatalog =
              await GetCatalogByIdUseCase().execute(selectedCatalog.id);
          final index =
              catalogsList.indexWhere((c) => c.id == selectedCatalog.id);
          if (index != -1) {
            catalogsList[index] = fullCatalog;
            catalogSelected.value = fullCatalog;
          }
          debugPrint(
              '=== Loaded items for catalog ${selectedCatalog.id}: ${fullCatalog.items?.length ?? 0} items ===');
        } catch (e) {
          debugPrint('Error loading catalog items: $e');
        }
      }

      isLoadingCatalogs.value = false;
      _isLoadingCatalogsInternal = false;
      update();
    } on ApiException catch (e) {
      _isLoadingCatalogsInternal = false;
      isLoadingCatalogs.value = false;
      debugPrint('Error loading catalogs: ${e.statusCode} - ${e.message}');
      update();
      if (e.statusCode == 404) {
        catalogsList.clear();
        update();
        return;
      }
      rethrow;
    } catch (e) {
      _isLoadingCatalogsInternal = false;
      isLoadingCatalogs.value = false;
      debugPrint('Unexpected error loading catalogs: $e');
      rethrow;
    }
  }

  void changeCatalogSelected(CatalogModel select) async {
    catalogSelected.value = select;
    update();

    // Cargar los items del catálogo seleccionado
    try {
      final fullCatalog = await GetCatalogByIdUseCase().execute(select.id);
      final index = catalogsList.indexWhere((c) => c.id == select.id);
      if (index != -1) {
        catalogsList[index] = fullCatalog;
        catalogSelected.value = fullCatalog;
      }
      debugPrint(
          '=== Loaded items for catalog ${select.id}: ${fullCatalog.items?.length ?? 0} items ===');
      update();
    } catch (e) {
      debugPrint('Error loading catalog items: $e');
    }
  }

  TextEditingController nameCatalog = TextEditingController();
  TextEditingController descriptionCatalog = TextEditingController();
  bool isPublicCatalog = true;
  Uint8List? coverImageCatalog;
  List<String> tagsCatalog = [];

  void pickCoverImageCatalog() async {
    final ImagePicker pickerImage = ImagePicker();
    final result = await pickerImage.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final String extension = result.name.split('.').last.toLowerCase();
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
      Uint8List reducedFile = ImageSizeHelper.resizeIfNeeded(originalFile);
      coverImageCatalog = reducedFile;
      update();
    }
  }

  void updateTagsCatalogSelected({required List<String> tags}) {
    tagsCatalog = tags;
    update();
  }

  void changeIsPublicCatalog(bool val) {
    isPublicCatalog = val;
    update();
  }

  Future<CatalogModel?> createCatalog(String type) async {
    final catalogName =
        nameCatalog.text.isNotEmpty ? nameCatalog.text : 'Nuevo catálogo';
    try {
      isLoadingCatalogs.value = true;
      update();

      final newCatalog = await CreateCatalogUseCase().execute(
        CreateCatalogParams(
          catalogType: type,
          name: catalogName,
          description: descriptionCatalog.text.isNotEmpty
              ? descriptionCatalog.text
              : null,
          isPublic: isPublicCatalog,
          tags: tagsCatalog.isNotEmpty ? tagsCatalog : null,
          coverImage: coverImageCatalog,
        ),
      );

      isLoadingCatalogs.value = false;
      update();

      GlobalDialogsHandles.snackbarSuccess(
        title: 'Catálogo creado',
        message: '$catalogName se creó exitosamente',
      );

      clearCatalogForm();

      catalogsList.add(newCatalog);
      catalogSelected.value = newCatalog;
      update();
      return newCatalog;
    } on ApiException catch (apiError) {
      isLoadingCatalogs.value = false;
      update();
      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo crear el catálogo',
        defaultErrorMessage: 'Error al crear el catálogo',
      );
      return null;
    } catch (e) {
      isLoadingCatalogs.value = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al crear el catálogo. Inténtalo de nuevo.',
      );
      return null;
    }
  }

  Future<CatalogModel?> editCatalog(CatalogModel catalog) async {
    try {
      isLoadingCatalogs.value = true;
      update();

      final updatedCatalog = await UpdateCatalogUseCase().execute(
        UpdateCatalogParams(
          catalogId: catalog.id,
          name: nameCatalog.text,
          description: descriptionCatalog.text.isNotEmpty
              ? descriptionCatalog.text
              : null,
          isPublic: isPublicCatalog,
          tags: tagsCatalog.isNotEmpty ? tagsCatalog : null,
          coverImage: coverImageCatalog,
        ),
      );

      isLoadingCatalogs.value = false;
      update();

      final index = catalogsList.indexWhere((c) => c.id == catalog.id);
      if (index != -1) {
        catalogsList[index] = updatedCatalog;
      }

      if (catalogSelected.value?.id == catalog.id) {
        catalogSelected.value = updatedCatalog;
      }

      GlobalDialogsHandles.snackbarSuccess(
        title: 'Catálogo actualizado',
        message:
            '${updatedCatalog.name ?? 'El catálogo'} se actualizó exitosamente',
      );

      update();
      return updatedCatalog;
    } on ApiException catch (apiError) {
      isLoadingCatalogs.value = false;
      update();
      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo actualizar el catálogo',
        defaultErrorMessage: 'Error al actualizar el catálogo',
      );
      return null;
    } catch (e) {
      isLoadingCatalogs.value = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperada',
        message:
            'Ocurrió un error al actualizar el catálogo. Inténtalo de nuevo.',
      );
      return null;
    }
  }

  Future<void> deleteCatalog(CatalogModel catalog) async {
    try {
      var isConfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar el catálogo?',
        message: 'Todos los productos cargados en él se eliminarán',
      );

      if (isConfirm) {
        isLoadingCatalogs.value = true;
        update();

        await DeleteCatalogUseCase().execute(catalog.id);

        catalogsList.removeWhere((c) => c.id == catalog.id);

        if (catalogSelected.value?.id == catalog.id) {
          catalogSelected.value =
              catalogsList.isNotEmpty ? catalogsList.first : null;
        }

        isLoadingCatalogs.value = false;
        update();

        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${catalog.description} con éxito.',
        );
      }
    } on ApiException {
      isLoadingCatalogs.value = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message:
            'No se pudo eliminar ${catalog.description}, vuelve a intentarlo más tarde.',
      );
    } catch (e) {
      GlobalDialogsHandles.snackbarError(
        title: '¡Ups!',
        message:
            'No se pudo eliminar ${catalog.description}, vuelve a intentarlo más tarde.',
      );
    }
  }

  void clearCatalogForm() {
    nameCatalog.clear();
    descriptionCatalog.clear();
    isPublicCatalog = true;
    tagsCatalog = [];
    coverImageCatalog = null;
    update();
  }

  void gotoEditCatalog(CatalogModel catalog) async {
    nameCatalog.text = catalog.name ?? catalog.description ?? '';
    descriptionCatalog.text = catalog.description ?? '';
    isPublicCatalog = catalog.isPublic;
    tagsCatalog = catalog.tags ?? [];
    coverImageCatalog = null;
    try {
      if (catalog.coverImageUrl != null && catalog.coverImageUrl!.isNotEmpty) {
        coverImageCatalog =
            await McFunctions().fetchImageAsUint8List(catalog.coverImageUrl!);
      }
    } catch (e) {
      debugPrint('Error loading image catalog: $e');
    }
    update();
  }

  TextEditingController nameItemController = TextEditingController();
  TextEditingController priceItemController = TextEditingController();
  TextEditingController descriptionItemController = TextEditingController();
  List<String> tagsItems = [];
  String photoItemController = '';

  Uint8List? fileTaked;
  Uint8List toSend = Uint8List(1);

  void updateTagsSelected({required List<String> tags}) {
    tagsItems = tags;
    update();
  }

  final RxBool isLoadingItems = false.obs;

  Future<String> uploadImage(Uint8List file) async {
    try {
      var responUrl = await UploadFileUsesCase().execute(file);
      return responUrl;
    } catch (e) {
      rethrow;
    }
  }

  void pickImageDirectory() async {
    final ImagePicker pickerImage = ImagePicker();
    final result = await pickerImage.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final String extension = result.name.split('.').last.toLowerCase();
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
      Uint8List reducedFile = ImageSizeHelper.resizeIfNeeded(originalFile);
      toSend = reducedFile;
      fileTaked = reducedFile;
      update();
    }
  }

  Future<CatalogItemModel?> createCatalogItem() async {
    if (catalogSelected.value == null) {
      GlobalDialogsHandles.snackbarError(
        title: 'Error',
        message: 'Selecciona un catálogo primero',
      );
      return null;
    }

    if (nameItemController.text.isEmpty || priceItemController.text.isEmpty) {
      GlobalDialogsHandles.snackbarError(
        title: 'Error',
        message: 'El nombre y precio son obligatorios',
      );
      return null;
    }

    try {
      isLoadingItems.value = true;
      update();

      Uint8List? photoData;
      if (toSend.isNotEmpty && toSend.length > 1) {
        photoItemController = await uploadImage(toSend);
        photoData = toSend;
      }

      final newItem = await CreateCatalogItemUseCase().execute(
        CreateCatalogItemParams(
          catalogId: catalogSelected.value!.id,
          name: nameItemController.text,
          price: double.tryParse(priceItemController.text) ?? 0.0,
          description: descriptionItemController.text.isEmpty
              ? null
              : descriptionItemController.text,
          tags: tagsItems.isEmpty ? null : tagsItems,
          photo: photoData,
        ),
      );

      isLoadingItems.value = false;
      update();

      GlobalDialogsHandles.snackbarSuccess(
        title: 'Genial',
        message: '${newItem.name} cargado con éxito!',
      );

      clearItemForm();
      update();
      return newItem;
    } on ApiException catch (apiError) {
      isLoadingItems.value = false;
      update();
      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo crear el producto',
        defaultErrorMessage: 'Error al crear el producto',
      );
      return null;
    } catch (e) {
      isLoadingItems.value = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al crear el producto. Inténtalo de nuevo.',
      );
      return null;
    }
  }

  CatalogItemModel itemToEdit = CatalogItemModel(
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

  Future<CatalogItemModel?> editCatalogItem() async {
    if (catalogSelected.value == null) {
      return null;
    }

    try {
      isLoadingItems.value = true;
      update();

      String? photoUrl;
      if (toSend.isNotEmpty && toSend.length > 1) {
        photoUrl = await uploadImage(toSend);
      }

      final updatedItem = await UpdateCatalogItemUseCase().execute(
        UpdateCatalogItemParams(
          catalogId: catalogSelected.value!.id,
          itemId: itemToEdit.id,
          name:
              nameItemController.text.isEmpty ? null : nameItemController.text,
          description: descriptionItemController.text.isEmpty
              ? null
              : descriptionItemController.text,
          photoURL: photoUrl,
          price: double.tryParse(priceItemController.text),
          tags: tagsItems.isEmpty ? null : tagsItems,
        ),
      );

      isLoadingItems.value = false;
      update();

      GlobalDialogsHandles.snackbarSuccess(
        title: '¡Perfecto!',
        message: '${nameItemController.text} se actualizó exitosamente',
      );

      update();
      return updatedItem;
    } on ApiException catch (apiError) {
      isLoadingItems.value = false;
      update();
      _handleApiError(
        apiError,
        defaultErrorTitle: 'No se pudo actualizar el producto',
        defaultErrorMessage: 'Error al actualizar el producto',
      );
      return null;
    } catch (e) {
      isLoadingItems.value = false;
      update();
      GlobalDialogsHandles.snackbarError(
        title: 'Error inesperado',
        message: 'Ocurrió un error al actualizar. Inténtalo de nuevo.',
      );
      return null;
    }
  }

  Future<void> deleteCatalogItem(CatalogItemModel item) async {
    try {
      var isConfirm = await GlobalDialogsHandles.dialogConfirm(
        title: '¿Seguro desea eliminar ${item.name}?',
        message: '',
      );
      if (!isConfirm) return;

      await DeleteCatalogItemUseCase().execute(
        catalogId: catalogSelected.value!.id,
        itemId: item.id,
      );
      GlobalDialogsHandles.snackbarSuccess(
        title: '¡Perfecto!',
        message: 'Se eliminó ${item.name} con éxito.',
      );
      // Recargar los items del catálogo
      await _reloadCatalogItems();
    } catch (e) {
      debugPrint('Error deleting catalog item: $e');
      if (e.toString().contains('200') || e.toString().contains('204')) {
        // La eliminación fue exitosa pero hubo un problema con la respuesta
        GlobalDialogsHandles.snackbarSuccess(
          title: '¡Perfecto!',
          message: 'Se eliminó ${item.name} con éxito.',
        );
        await _reloadCatalogItems();
      } else {
        GlobalDialogsHandles.snackbarError(
          title: '¡Ups!',
          message:
              'No se pudo eliminar ${item.name}, vuelve a intentarlo más tarde.',
        );
      }
    }
  }

  Future<void> _reloadCatalogItems() async {
    if (catalogSelected.value == null) return;
    try {
      final fullCatalog =
          await GetCatalogByIdUseCase().execute(catalogSelected.value!.id);
      final index =
          catalogsList.indexWhere((c) => c.id == catalogSelected.value!.id);
      if (index != -1) {
        catalogsList[index] = fullCatalog;
        catalogSelected.value = fullCatalog;
      }
      update();
    } catch (e) {
      debugPrint('Error reloading catalog items: $e');
    }
  }

  void gotoEditItem(CatalogItemModel item) async {
    nameItemController.text = item.name;
    priceItemController.text = item.price.toString();
    descriptionItemController.text = item.description ?? '';
    tagsItems = item.tags ?? [];
    photoItemController = item.photoURL ?? '';
    itemToEdit = item;
    try {
      var resultImage =
          await McFunctions().fetchImageAsUint8List(photoItemController);
      fileTaked = resultImage;
      toSend = fileTaked!;
      update();
    } catch (e) {
      debugPrint('Error loading image: $e');
    }

    // Navegar a la ruta correcta según el tipo de catálogo
    if (_currentType == typeWardrobe || _currentType == typeService) {
      Get.toNamed('/editar-prenda');
    } else {
      Get.toNamed('/edit-menu-item');
    }
  }

  void clearItemForm() {
    nameItemController.clear();
    priceItemController.clear();
    descriptionItemController.clear();
    tagsItems = [];
    photoItemController = '';
    toSend = Uint8List(1);
    fileTaked = null;
    itemToEdit = CatalogItemModel(
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
  }

  String get currentType => _currentType;

  void _handleApiError(
    ApiException apiError, {
    required String defaultErrorTitle,
    required String defaultErrorMessage,
  }) {
    String errorMessage = defaultErrorMessage;
    try {
      String apiMessage = apiError.message.trim();
      
      try {
        // Option 1: It's valid JSON
        final decoded = jsonDecode(apiMessage);
        if (decoded is Map && decoded.containsKey('message')) {
          apiMessage = decoded['message'].toString();
        }
      } catch (_) {
        // Option 2: It's a Map toString() representation (Dart default behavior for dynamic objects)
        if (apiMessage.startsWith('{') && apiMessage.contains('message:')) {
          final match = RegExp(r'message:\s*(.+?)(?:,\s*[a-zA-Z0-9_]+:|})').firstMatch(apiMessage);
          if (match != null && match.groupCount >= 1) {
            apiMessage = match.group(1)!.trim();
          }
        }
      }
      
      errorMessage = apiMessage.isNotEmpty ? apiMessage : defaultErrorMessage;

      if (errorMessage.toLowerCase().contains('límites') ||
          errorMessage.toLowerCase().contains('plan free') ||
          errorMessage.toLowerCase().contains('no puedes crear más')) {
        GlobalDialogsHandles.showPlanLimitDialog(
          title: 'Límite del Plan Gratuito',
          message: errorMessage,
          onUpgradePressed: () {
            GlobalDialogsHandles.snackbarError(
              title: 'Función en desarrollo',
              message: 'La actualización del plan estará disponible pronto.',
            );
          },
        );
        return;
      }
    } catch (e) {
      String apiMessage = apiError.message.trim();
      
      try {
        final decoded = jsonDecode(apiMessage);
        if (decoded is Map && decoded.containsKey('message')) {
          apiMessage = decoded['message'].toString();
        }
      } catch (_) {
        if (apiMessage.startsWith('{') && apiMessage.contains('message:')) {
          final match = RegExp(r'message:\s*(.+?)(?:,\s*[a-zA-Z0-9_]+:|})').firstMatch(apiMessage);
          if (match != null && match.groupCount >= 1) {
            apiMessage = match.group(1)!.trim();
          }
        }
      }
      
      errorMessage = apiMessage.isNotEmpty ? apiMessage : defaultErrorMessage;
    }

    final finalMessage = errorMessage.trim();
    final validMessage =
        finalMessage.isNotEmpty ? finalMessage : defaultErrorMessage;

    GlobalDialogsHandles.snackbarError(
      title: defaultErrorTitle,
      message: validMessage,
    );
  }
}
