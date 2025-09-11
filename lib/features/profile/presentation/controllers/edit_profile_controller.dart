import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

/// Controlador para la edición de perfil de usuario
///
/// Maneja la lógica de negocio para actualizar datos del usuario
/// incluyendo nombre, email, teléfono y foto de perfil.
class EditProfileController extends GetxController {
  // Controllers para los campos del formulario
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de la imagen
  Uint8List? _selectedImageBytes;
  Uint8List? get selectedImageBytes => _selectedImageBytes;

  String? _currentImageUrl;
  String? get currentImageUrl => _currentImageUrl;

  // Instancia del picker de imágenes
  final ImagePicker _imagePicker = ImagePicker();

  // Referencia al controlador principal
  late DinningController _dinningController;

  @override
  void onInit() {
    super.onInit();
    _dinningController = Get.find<DinningController>();
    _initializeForm();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Inicializa el formulario con los datos actuales del usuario
  void _initializeForm() {
    final user = _dinningController.dinningLogin;
    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
    phoneController.text = user.phone ?? '';
    _currentImageUrl = user.photoURL;
  }

  /// Selecciona una imagen de la galería
  Future<void> selectImage() async {
    try {
      final XFile? result = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (result != null) {
        _selectedImageBytes = await result.readAsBytes();
        update();
      }
    } catch (e) {
      _showErrorSnackbar('Error al seleccionar imagen: $e');
    }
  }

  /// Elimina la imagen seleccionada
  void removeSelectedImage() {
    _selectedImageBytes = null;
    update();
  }

  /// Resetea el formulario a los valores originales
  void resetForm() {
    _selectedImageBytes = null;
    _initializeForm();
    update();
  }

  /// Valida los campos del formulario
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('El nombre es obligatorio');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _showErrorSnackbar('El email es obligatorio');
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      _showErrorSnackbar('El formato del email no es válido');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      _showErrorSnackbar('El teléfono es obligatorio');
      return false;
    }

    return true;
  }

  /// Guarda los cambios del perfil
  Future<void> saveProfile() async {
    if (!_validateForm()) return;

    // Verificar si hay cambios antes de enviar
    if (!hasChanges) {
      _showErrorSnackbar('No hay cambios que guardar');
      return;
    }

    try {
      _isLoading = true;
      update();

      // Obtener ID del usuario actual
      final userId = _dinningController.dinningLogin.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // Crear la request para actualizar el usuario
      final request = UpdateUserRequest(
        userId: userId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        photoBytes: _selectedImageBytes,
        photoFilename:
            _selectedImageBytes != null ? 'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg' : null,
      );

      // Llamar al usecase para actualizar el usuario
      final updateUseCase = UpdateUserUseCase();
      final response = await updateUseCase.call(request);

      if (response.success) {
        // Solo actualizar si la respuesta es exitosa
        _updateDinningControllerData(response.userData);

        // Limpiar la imagen seleccionada ya que se guardó exitosamente
        _selectedImageBytes = null;

        // Volver a la pantalla anterior
        Get.back();

        // Mostrar mensaje de éxito después de la navegación
        Future.delayed(const Duration(milliseconds: 300), () {
          _showSuccessSnackbar('Tu perfil ha sido actualizado exitosamente');
        });
      } else {
        // Si falla, no se actualiza nada en el DinningController
        throw Exception(response.message);
      }
    } catch (e) {
      // En caso de error, mantener los datos originales
      _showErrorSnackbar('Error al actualizar el perfil: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Actualiza los datos en el DinningController de forma segura
  void _updateDinningControllerData(Map<String, dynamic>? userData) {
    if (userData != null) {
      // Actualizar con los datos del servidor (preferible)
      _dinningController.dinningLogin.name = userData['name'] ?? nameController.text.trim();
      _dinningController.dinningLogin.email = userData['email'] ?? emailController.text.trim();
      _dinningController.dinningLogin.phone = userData['phone'] ?? phoneController.text.trim();

      // Solo actualizar la foto si viene del servidor
      if (userData['photoURL'] != null) {
        _dinningController.dinningLogin.photoURL = userData['photoURL'];
      }
    } else {
      // Fallback: actualizar con los valores del formulario
      _dinningController.dinningLogin.name = nameController.text.trim();
      _dinningController.dinningLogin.email = emailController.text.trim();
      _dinningController.dinningLogin.phone = phoneController.text.trim();
    }

    // Forzar la actualización del DinningController para que se refleje en toda la app
    _dinningController.update();
  }

  /// Muestra un snackbar de error
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      '❌ Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[50],
      colorText: Colors.red[800],
      borderColor: Colors.red[300],
      borderWidth: 1,
      icon: Icon(Icons.error_outline, color: Colors.red[700], size: 24),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Muestra un snackbar de éxito
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      '✅ Éxito',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[50],
      colorText: Colors.green[800],
      borderColor: Colors.green[300],
      borderWidth: 1,
      icon: Icon(Icons.check_circle_outline, color: Colors.green[700], size: 24),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Verifica si hay cambios pendientes
  bool get hasChanges {
    final user = _dinningController.dinningLogin;
    return nameController.text.trim() != (user.name ?? '') ||
        emailController.text.trim() != (user.email ?? '') ||
        phoneController.text.trim() != (user.phone ?? '') ||
        _selectedImageBytes != null;
  }
}
