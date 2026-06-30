import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/features/business_selection/models/business_type.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pickmeup_dashboard/core/analytics_service.dart';

class CreateCommerceController extends GetxController {
  final nameCtrl = TextEditingController();
  final slugCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final selectedType = Rx<BusinessType?>(null);
  final isCreating = false.obs;
  final isPickingLogo = false.obs;
  final currentStep = 0.obs;
  Uint8List? _logoBytes;

  Uint8List? get logoBytes => _logoBytes;

  set logoBytes(Uint8List? value) {
    _logoBytes = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    nameCtrl.addListener(_autoGenerateSlug);
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        if (nameCtrl.text.trim().isEmpty) {
          GlobalDialogsHandles.snackbarError(
            title: 'Error',
            message: 'El nombre del negocio es obligatorio',
          );
          return false;
        }
        if (slugCtrl.text.trim().isEmpty) {
          GlobalDialogsHandles.snackbarError(
            title: 'Error',
            message: 'El slug es obligatorio',
          );
          return false;
        }
        if (!RegExp(r'^[a-z0-9-]+$').hasMatch(slugCtrl.text.trim())) {
          GlobalDialogsHandles.snackbarError(
            title: 'Error',
            message: 'El slug solo puede contener letras minúsculas, números y guiones',
          );
          return false;
        }
        return true;
      case 1:
        if (selectedType.value == null) {
          GlobalDialogsHandles.snackbarError(
            title: 'Error',
            message: 'Debes seleccionar un tipo de negocio',
          );
          return false;
        }
        return true;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void nextStep() {
    if (validateStep(currentStep.value)) {
      if (currentStep.value < 2) {
        currentStep.value++;
        update();
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      update();
    }
  }

  void goToStep(int step) {
    if (step < currentStep.value) {
      currentStep.value = step;
      update();
    } else if (step > currentStep.value) {
      if (validateStep(currentStep.value)) {
        currentStep.value = step;
        update();
      }
    }
  }

  void _autoGenerateSlug() {
    String name = nameCtrl.text.trim().toLowerCase();
    if (name.isEmpty) {
      slugCtrl.text = '';
      return;
    }
    String slug = name
        .replaceAll(RegExp(r'[áäàâ]'), 'a')
        .replaceAll(RegExp(r'[éëèê]'), 'e')
        .replaceAll(RegExp(r'[íïìî]'), 'i')
        .replaceAll(RegExp(r'[óöòô]'), 'o')
        .replaceAll(RegExp(r'[úüùû]'), 'u')
        .replaceAll(RegExp(r'ñ'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    slugCtrl.text = slug;
  }

  void selectType(BusinessType type) {
    selectedType.value = type;
    update();
  }

  Future<void> createCommerce() async {
    if (nameCtrl.text.trim().isEmpty) {
      GlobalDialogsHandles.snackbarError(
        title: 'Error',
        message: 'El nombre del negocio es obligatorio',
      );
      return;
    }
    if (selectedType.value == null) {
      GlobalDialogsHandles.snackbarError(
        title: 'Error',
        message: 'Debes seleccionar un tipo de negocio',
      );
      return;
    }

    isCreating.value = true;
    update();

    try {
      final type = selectedType.value!;
      final context = type.backendCode.isNotEmpty ? type.backendCode : RolesFuncionts.toBusinessContext(type.roleType).value;

      final newCommerce = await CreateCommerceUseCase().execute(
        CreateCommerceRequest(
          businessName: nameCtrl.text.trim(),
          slug: slugCtrl.text.trim(),
          context: context,
          businessType: type.id,
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
          logoBytes: _logoBytes,
        ),
      );

      final response = await SwitchContextUseCase().execute(
        SwitchContextRequest(commerceId: newCommerce.id),
      );
      API.setAccessToken(response.accessToken);

      final dinning = Get.find<DinningController>();
      dinning.dinningLogin.commerceId = response.commerceId;
      dinning.dinningLogin.businessName = newCommerce.businessName;
      dinning.dinningLogin.slug = newCommerce.slug;
      dinning.getMyDinningInfo();

      Get.offAllNamed('/');
    } on ApiException catch (e) {
      AnalyticsService().logError(e.toString(), context: 'create_commerce_controller.createCommerce');
      if (e.statusCode == 400 && e.message.toLowerCase().contains('límite')) {
        GlobalDialogsHandles.showPlanLimitDialog(
          title: 'Límite de comercios alcanzado',
          message: e.message,
          onUpgradePressed: () => Get.toNamed(PURoutes.MEMBERSHIP),
        );
      } else {
        GlobalDialogsHandles.snackbarError(
          title: 'Error',
          message: e.message,
        );
      }
    } catch (e) {
      AnalyticsService().logError(e.toString(), context: 'create_commerce_controller.createCommerce');
      GlobalDialogsHandles.snackbarError(
        title: 'Error',
        message: 'No se pudo crear el negocio: $e',
      );
    } finally {
      isCreating.value = false;
      update();
    }
  }

  @override
  void onClose() {
    nameCtrl.removeListener(_autoGenerateSlug);
    nameCtrl.dispose();
    slugCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}
