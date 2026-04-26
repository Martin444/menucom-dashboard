import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/update_user_role/data/usescases/update_user_role_usecase.dart';
import 'package:menu_dart_api/by_feature/user/update_user_role/model/update_user_role_request.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import '../../models/business_type.dart';
import '../../../home/controllers/dinning_controller.dart';

/// Controlador para la selección de tipo de negocio
class BusinessSelectionController extends GetxController {
  // Estado de carga
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Tipo de negocio seleccionado
  final Rx<BusinessType?> _selectedBusinessType = Rx<BusinessType?>(null);
  BusinessType? get selectedBusinessType => _selectedBusinessType.value;

  // Use case para actualizar rol del usuario actual
  final UpdateUserRoleUseCase _updateUserRoleUseCase = UpdateUserRoleUseCase();

  // Controller del home para refrescar datos
  late DinningController _dinningController;

  @override
  void onInit() {
    super.onInit();
    _dinningController = Get.find<DinningController>();
  }

  /// Seleccionar un tipo de negocio
  void selectBusinessType(BusinessType businessType) {
    _selectedBusinessType.value = businessType;
  }

  /// Confirmar la selección y actualizar el rol del usuario
  Future<void> confirmSelection() async {
    if (_selectedBusinessType.value == null) {
      _showErrorSnackbar('Por favor selecciona un tipo de negocio');
      return;
    }

    try {
      _isLoading.value = true;

      // Print del rol seleccionado
      debugPrint(
          '🎯 ROL SELECCIONADO: ${_selectedBusinessType.value!.title} (${_selectedBusinessType.value!.roleType.name})');

      // Crear request para el nuevo endpoint seguro
      final request = UpdateUserRoleRequest(
        role: _selectedBusinessType.value!.roleType.name,
      );

      // Llamar al API con el nuevo endpoint PATCH /user-roles/my-role
      final response = await _updateUserRoleUseCase.call(request);

      if (response.success) {
        // Actualizar datos locales
        _dinningController.dinningLogin.role = _selectedBusinessType.value!.roleType.name;

        // Mostrar mensaje de éxito
        _showSuccessSnackbar('¡Tipo de negocio actualizado exitosamente!');

        // Ir directamente al Home sin importar el stack de navegación
        Get.offAllNamed(PURoutes.HOME);

        // Refrescar datos del usuario
        _dinningController.getMyDinningInfo();
      } else {
        throw Exception(response.message ?? 'Error desconocido');
      }
    } catch (e) {
      _showErrorSnackbar('Error al actualizar: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Mostrar snackbar de error
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      '❌ Error',
      message,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  /// Mostrar snackbar de éxito
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      '✅ Éxito',
      message,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  /// Cancelar y regresar al Home
  void cancel() {
    // Ir al Home sin importar el stack de navegación
    Get.offAllNamed('/home');
  }
}
