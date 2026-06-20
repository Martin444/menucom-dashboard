import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/by_feature/commerce/models/commerce.dart';
import 'package:menu_dart_api/by_feature/commerce/models/commerce_requests.dart';
import 'package:menu_dart_api/by_feature/commerce/data/usecase/commerce_usecases.dart';
import 'package:menu_dart_api/by_feature/auth/my_contexts/data/usecase/get_my_contexts_usecase.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

class BusinessProfileController extends GetxController {
  final nameController = TextEditingController();
  final slugController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final websiteController = TextEditingController();

  bool isLoading = false;
  final isSaving = false.obs;

  Uint8List? selectedLogoBytes;
  Uint8List? selectedCoverBytes;
  String? currentLogoUrl;
  String? currentCoverUrl;

  final ImagePicker imagePicker = ImagePicker();
  DinningController? _dinningController;

  Worker? _dinningWorker;
  late VoidCallback _textListener;

  String? get _commerceId => _dinningController?.dinningLogin.commerceId;

  @override
  void onInit() {
    super.onInit();
    _dinningController = Get.find<DinningController>();
    _setupTextListeners();
    _loadFuture = _loadCommerceData();

    _dinningWorker = ever(
      _dinningController!.isLoadingDataUser,
      (_) async {
        if (!_dinningController!.isLoadingDataUser.value) {
          _loadFuture = _loadCommerceData();
          update();
        }
      },
    );
  }

  @override
  void onClose() {
    _removeTextListeners();
    _dinningWorker?.dispose();
    nameController.dispose();
    slugController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    addressController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    websiteController.dispose();
    super.onClose();
  }

  void _setupTextListeners() {
    _textListener = () => update();
    nameController.addListener(_textListener);
    slugController.addListener(_textListener);
    descriptionController.addListener(_textListener);
    phoneController.addListener(_textListener);
    addressController.addListener(_textListener);
    instagramController.addListener(_textListener);
    facebookController.addListener(_textListener);
    websiteController.addListener(_textListener);
  }

  void _removeTextListeners() {
    nameController.removeListener(_textListener);
    slugController.removeListener(_textListener);
    descriptionController.removeListener(_textListener);
    phoneController.removeListener(_textListener);
    addressController.removeListener(_textListener);
    instagramController.removeListener(_textListener);
    facebookController.removeListener(_textListener);
    websiteController.removeListener(_textListener);
  }

  late Future<Commerce?> _loadFuture;
  Future<Commerce?> get loadFuture => _loadFuture;

  Future<Commerce?> _loadCommerceData() async {
    if (_dinningController?.dinningLogin == null) return null;

    if (_dinningController!.dinningLogin.commerceId == null ||
        _dinningController!.dinningLogin.commerceId!.isEmpty) {
      debugPrint('BusinessProfileController: commerceId is null, fetching from my-contexts...');
      await _fetchCommerceIdFromContexts();
    }

    final currentCommerceId = _dinningController?.dinningLogin.commerceId;
    if (currentCommerceId == null || currentCommerceId.isEmpty) {
      debugPrint('BusinessProfileController: commerceId still null after my-contexts');
      return null;
    }

    try {
      final commerce = await GetCommerceByIdUseCase().execute(currentCommerceId);
      _syncDinningFromCommerce(commerce);
      _fillControllers(commerce);
      return commerce;
    } catch (e) {
      debugPrint('BusinessProfileController: error fetching commerce by id: $e');
      debugPrint('BusinessProfileController: trying fallback via getMyCommerces...');
    }

    try {
      final commerces = await GetMyCommercesUseCase().execute();
      if (commerces.isNotEmpty) {
        final commerce = commerces.first;
        _dinningController?.dinningLogin.commerceId = commerce.id;
        _syncDinningFromCommerce(commerce);
        _fillControllers(commerce);
        debugPrint('BusinessProfileController: fallback commerce loaded: ${commerce.id}');
        return commerce;
      }
    } catch (e) {
      debugPrint('BusinessProfileController: error in getMyCommerces fallback: $e');
    }

    return null;
  }

  void _fillControllers(Commerce commerce) {
    _removeTextListeners();

    nameController.text = commerce.businessName;
    slugController.text = commerce.slug;
    descriptionController.text = commerce.description ?? '';
    phoneController.text = commerce.phone ?? '';
    addressController.text = commerce.address ?? '';

    currentLogoUrl = commerce.logoUrl;
    currentCoverUrl = commerce.coverImageUrl;

    final socialLinks = commerce.metadata;
    instagramController.text = socialLinks?['instagram'] as String? ?? '';
    facebookController.text = socialLinks?['facebook'] as String? ?? '';
    websiteController.text = socialLinks?['website'] as String? ?? '';

    _setupTextListeners();
  }

  void _syncDinningFromCommerce(Commerce commerce) {
    final dinning = _dinningController?.dinningLogin;
    if (dinning == null) return;

    dinning.commerceId = commerce.id;
    dinning.businessName = commerce.businessName;
    dinning.slug = commerce.slug;
    dinning.businessDescription = commerce.description;
    dinning.businessPhone = commerce.phone;
    dinning.businessAddress = commerce.address;
    dinning.photoURL = commerce.logoUrl;
    dinning.coverImageUrl = commerce.coverImageUrl;
    dinning.socialLinks = commerce.metadata;
  }

  Future<void> _fetchCommerceIdFromContexts() async {
    try {
      final commerces = await GetMyCommercesUseCase().execute();
      if (commerces.isNotEmpty) {
        final currentCommerce = commerces.firstWhere(
          (c) => c.id == _dinningController?.dinningLogin.commerceId,
          orElse: () => commerces.first,
        );
        _dinningController?.dinningLogin.commerceId = currentCommerce.id;
        debugPrint('BusinessProfileController: commerceId fetched from getMyCommerces: ${currentCommerce.id}');
        return;
      }
    } catch (e) {
      debugPrint('BusinessProfileController: error fetching my commerces: $e');
    }

    try {
      final contexts = await GetMyContextsUseCase().execute();
      if (contexts.isNotEmpty) {
        final currentContext = contexts.firstWhere(
          (c) => c.isCurrent,
          orElse: () => contexts.first,
        );
        _dinningController?.dinningLogin.commerceId = currentContext.id;
        debugPrint('BusinessProfileController: commerceId fetched from my-contexts: ${currentContext.id}');
      } else {
        debugPrint('BusinessProfileController: my-contexts returned empty list');
      }
    } catch (e) {
      debugPrint('BusinessProfileController: error fetching my-contexts: $e');
    }
  }

  Future<void> selectLogo() async {
    try {
      final result = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (result != null) {
        selectedLogoBytes = await result.readAsBytes();
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al seleccionar logo: $e');
    }
  }

  Future<void> selectCover() async {
    try {
      final result = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (result != null) {
        selectedCoverBytes = await result.readAsBytes();
        update();
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al seleccionar portada: $e');
    }
  }

  void removeLogo() {
    selectedLogoBytes = null;
    currentLogoUrl = null;
    update();
  }

  void removeCover() {
    selectedCoverBytes = null;
    currentCoverUrl = null;
    update();
  }

  bool get hasChanges {
    final user = _dinningController?.dinningLogin;
    if (user == null) return false;

    return nameController.text.trim() != (user.businessName ?? '') ||
        slugController.text.trim() != (user.slug ?? '') ||
        descriptionController.text.trim() != (user.businessDescription ?? '') ||
        phoneController.text.trim() != (user.businessPhone ?? '') ||
        addressController.text.trim() != (user.businessAddress ?? '') ||
        selectedLogoBytes != null ||
        selectedCoverBytes != null ||
        _socialLinksChanged(user);
  }

  bool _socialLinksChanged(dynamic user) {
    final social = user.socialLinks as Map<String, dynamic>?;
    return instagramController.text.trim() != (social?['instagram'] ?? '') ||
        facebookController.text.trim() != (social?['facebook'] ?? '') ||
        websiteController.text.trim() != (social?['website'] ?? '');
  }

  Map<String, String> _buildSocialLinks() {
    final social = <String, String>{};
    if (instagramController.text.trim().isNotEmpty) {
      social['instagram'] = instagramController.text.trim();
    }
    if (facebookController.text.trim().isNotEmpty) {
      social['facebook'] = facebookController.text.trim();
    }
    if (websiteController.text.trim().isNotEmpty) {
      social['website'] = websiteController.text.trim();
    }
    return social;
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre del negocio es obligatorio');
      return;
    }

    var commerceId = _commerceId;

    if (commerceId == null || commerceId.isEmpty) {
      debugPrint('BusinessProfileController: saveProfile - commerceId null, fetching from my-contexts...');
      try {
        final contexts = await GetMyContextsUseCase().execute();
        final current = contexts.firstWhereOrNull((c) => c.isCurrent);
        if (current != null) {
          commerceId = current.id;
          _dinningController?.dinningLogin.commerceId = commerceId;
          debugPrint('BusinessProfileController: saveProfile - commerceId resolved from my-contexts (isCurrent): $commerceId');
        } else if (contexts.isNotEmpty) {
          commerceId = contexts.first.id;
          _dinningController?.dinningLogin.commerceId = commerceId;
          debugPrint('BusinessProfileController: saveProfile - commerceId resolved from my-contexts (first): $commerceId');
        }
      } catch (e) {
        debugPrint('BusinessProfileController: saveProfile - my-contexts failed: $e');
      }
    }

    if (commerceId == null || commerceId.isEmpty) {
      debugPrint('BusinessProfileController: saveProfile - trying getMyCommerces as last resort...');
      try {
        final commerces = await GetMyCommercesUseCase().execute();
        if (commerces.isNotEmpty) {
          commerceId = commerces.first.id;
          _dinningController?.dinningLogin.commerceId = commerceId;
          debugPrint('BusinessProfileController: saveProfile - commerceId from getMyCommerces: $commerceId');
        }
      } catch (e) {
        debugPrint('BusinessProfileController: saveProfile - getMyCommerces failed: $e');
      }
    }

    if (commerceId == null || commerceId.isEmpty) {
      Get.snackbar('Error', 'No se encontró el negocio asociado');
      return;
    }

    isSaving.value = true;

    try {
      final socialLinks = _buildSocialLinks();

      final request = UpdateCommerceRequest(
        businessName: nameController.text.trim(),
        slug: slugController.text.trim().isNotEmpty ? slugController.text.trim() : null,
        description: descriptionController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        metadata: socialLinks.isNotEmpty ? socialLinks : null,
        logoBytes: selectedLogoBytes,
        coverImageBytes: selectedCoverBytes,
      );

      final updateUseCase = UpdateCommerceUseCase();
      await updateUseCase.execute(commerceId, request);

      _updateDinningData(socialLinks);

      selectedLogoBytes = null;
      selectedCoverBytes = null;

      Get.back();
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Perfil actualizado',
          'Los datos de tu negocio han sido guardados',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el perfil: $e');
    } finally {
      isSaving.value = false;
    }
  }

  void _updateDinningData(Map<String, String> socialLinks) {
    final dinning = _dinningController?.dinningLogin;
    if (dinning == null) return;

    dinning.businessName = nameController.text.trim();
    dinning.slug = slugController.text.trim();
    dinning.businessDescription = descriptionController.text.trim();
    dinning.businessPhone = phoneController.text.trim();
    dinning.businessAddress = addressController.text.trim();

    dinning.socialLinks = socialLinks;
    _dinningController?.update();
  }
}
