import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:menu_dart_api/by_feature/upload_images/data/usescases/upload_file_usescases.dart';
import 'package:menu_dart_api/by_feature/auth/login/data/usescase/login_usescase.dart';
import 'package:menu_dart_api/by_feature/auth/social_login/data/usecase/social_login_usecase.dart';
import 'package:menu_dart_api/by_feature/user/change_password/data/usecase/change_password_usescase.dart';
import 'package:menu_dart_api/by_feature/auth/register/data/usescase/register_commerce_usescase.dart';
import 'package:menu_dart_api/core/exeptions/api_exception.dart';
import 'package:menu_dart_api/core/type_comerce_model.dart';
import 'package:menu_dart_api/by_feature/user/change_password/model/change_password_params.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/succes_register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/entities/auth_params.dart';
import '../../domain/usecases/login_with_credentials_usecase.dart';
import '../../domain/usecases/login_with_social_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../config/firebase_config.dart';
import '../../../../core/config.dart';
import '../../../../core/functions/mc_functions.dart';
import 'package:pickmeup_dashboard/core/helpers/image_size_helper.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

/// Estados posibles de la autenticación
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Estados específicos para cada tipo de autenticación
enum AuthAction {
  none,
  loginTraditional,
  loginGoogle,
  loginApple,
  logout,
  checkingAuth,
  refreshingToken,
  registering,
  changingPassword,
}

/// Controlador unificado para el manejo de autenticación.
///
/// Este controlador centraliza toda la lógica de autenticación del dashboard,
/// incluyendo login tradicional, social, registro, recuperación de contraseña y gestión de estado.
class AuthController extends GetxController {
  // Casos de uso
  late final LoginWithCredentialsUseCase _loginWithCredentialsUseCase;
  late final LoginWithSocialUseCase _loginWithSocialUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  // Secure storage para persistencia de token
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'authenticated_user';

  // Estado reactivo
  final Rx<AuthState> _authState = AuthState.initial.obs;
  final Rx<AuthAction> _currentAction = AuthAction.none.obs;
  final Rx<AuthenticatedUser?> _currentUser = Rx<AuthenticatedUser?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isProcessing = false.obs;

  // Controladores de login tradicional
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Controladores de registro
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController newNameController = TextEditingController();
  final TextEditingController newPhoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  // Controladores de recuperación de contraseña
  final TextEditingController emailRecoveryController = TextEditingController();
  final TextEditingController codeRecoveryController = TextEditingController();
  final TextEditingController newPassRecoveryController = TextEditingController();
  final TextEditingController repeatPassRecoveryController = TextEditingController();

  // Controlador de nueva contraseña (para cambio post-login)
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController newPassRepeatController = TextEditingController();

  // Variables de estado reactivas
  final RxString errorTextEmail = ''.obs;
  final RxString errorTextPassword = ''.obs;
  final RxString errorTextName = ''.obs;
  final RxString errorTextPhone = ''.obs;
  final RxString errorEmailRecovery = ''.obs;
  final RxString errorCodeRecovery = ''.obs;
  final RxString errorPasswordRecovery = ''.obs;
  final RxString? errorRepitPass = ''.obs;

  final RxBool isLogging = false.obs;
  final RxBool isLoggingGoogle = false.obs;
  final RxBool isRegistering = false.obs;
  final RxBool isValidInit = false.obs;
  final RxInt pageValidation = 0.obs;

  // Imagen para registro
  Uint8List? fileTaked;
  Uint8List toSend = Uint8List(1);
  TypeComerceModel? comerceModelSelected;
  List<TypeComerceModel> listCommerceAvilable = TypeComerceModel.getAvailableCommerceTypes();

  // Getters para acceso externo
  AuthState get authState => _authState.value;
  AuthAction get currentAction => _currentAction.value;
  AuthenticatedUser? get currentUser => _currentUser.value;
  String get errorMessage => _errorMessage.value;
  bool get isProcessing => _isProcessing.value;
  bool get isAuthenticated => _authState.value == AuthState.authenticated && _currentUser.value != null;
  bool get isUnauthenticated => _authState.value == AuthState.unauthenticated;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeUseCases();
    await checkAuthenticationStatus();
    _initVersion();
  }

  void _initVersion() async {
    VERSION_APP = await McFunctions.getReleaseVersion();
    update();
  }

  /// Inicializa los casos de uso con las dependencias necesarias
  Future<void> _initializeUseCases() async {
    try {
      final repository = await AuthRepositoryFactory.create();

      _loginWithCredentialsUseCase = LoginWithCredentialsUseCase(repository);
      _loginWithSocialUseCase = LoginWithSocialUseCase(repository);
      _logoutUseCase = LogoutUseCase(repository);
      _getCurrentUserUseCase = GetCurrentUserUseCase(repository);

      debugPrint('Casos de uso de autenticación inicializados');
    } catch (e) {
      debugPrint('Error al inicializar casos de uso: $e');
      _setError('Error al inicializar el sistema de autenticación');
    }
  }

  /// Verifica el estado de autenticación al iniciar la aplicación
  Future<void> checkAuthenticationStatus() async {
    try {
      _setCurrentAction(AuthAction.checkingAuth);
      _setLoading(true);

      final token = await _loadSavedToken();

      if (token == null || token.isEmpty) {
        _setUnauthenticated();
        return;
      }

      // Configurar token en API
      API.setAccessToken(token);

      final user = await _getCurrentUserUseCase.executeWithRefresh();

      if (user != null) {
        _setAuthenticatedUser(user);
        debugPrint('Usuario autenticado encontrado: ${user.email}');
      } else {
        _setUnauthenticated();
        debugPrint('No hay usuario autenticado');
      }
    } catch (e) {
      debugPrint('Error al verificar estado de autenticación: $e');
      _setUnauthenticated();
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Login tradicional con email y contraseña
  Future<void> loginWithEmailAndPassword() async {
    try {
      isLogging.value = true;
      update();

      if (emailController.text.isEmpty) {
        throw ApiException(111, 'El email no puede estar vacío');
      }

      if (passwordController.text.isEmpty) {
        throw ApiException(102, 'La contraseña no puede estar vacía');
      }

      var responseLogin = await LoginUserUseCase().execute(
        emailController.text,
        passwordController.text,
      );

      // Guardar token de forma segura
      await _secureStorage.write(key: _tokenKey, value: responseLogin.accessToken);
      API.setAccessToken(responseLogin.accessToken);

      // Obtener datos del usuario
      final user = await _getCurrentUserUseCase.executeWithRefresh();
      if (user != null) {
        _setAuthenticatedUser(user);
        // Guardar usuario de forma segura
        await _secureStorage.write(key: _userKey, value: json.encode(user.toMap()));
      }

      isLogging.value = false;
      Get.offAllNamed(PURoutes.HOME);
      _clearLoginFields();
      update();
    } on ApiException catch (e) {
      isLogging.value = false;
      _handleLoginError(e);
      update();
    } on Exception catch (e) {
      isLogging.value = false;
      Get.snackbar(
        'Error al Iniciar sesión',
        'No podemos traerte información, vuelve a intentarlo.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Error en login: $e');
    }
  }

  /// Manejo de errores de login
  void _handleLoginError(ApiException e) {
    if (e.statusCode == 102) {
      errorTextPassword.value = e.message;
    } else if (e.statusCode == 401) {
      errorTextEmail.value = '';
      errorTextPassword.value = e.message;
    } else if (e.statusCode == 404) {
      errorTextPassword.value = '';
      errorTextEmail.value = e.message;
    } else if (e.statusCode == 111) {
      errorTextEmail.value = e.message;
    }
  }

  /// Limpia los campos de login
  void _clearLoginFields() {
    emailController.clear();
    passwordController.clear();
    errorTextEmail.value = '';
    errorTextPassword.value = '';
  }

  /// Validación del botón de login
  bool validateBtnLoginUser() {
    var isEmail = _isValidEmail(emailController.text);
    if (!isEmail && emailController.text.length >= 4) {
      errorTextEmail.value = 'Ingresa un email válido';
    } else {
      errorTextEmail.value = '';
    }

    var validateItems = (emailController.text.isNotEmpty && passwordController.text.isNotEmpty);

    isValidInit.value = validateItems;
    update();
    return validateItems;
  }

  /// Validación de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validación de repetición de contraseña
  bool validateRepeatPass() {
    final newPassword = newPassController.text;
    final repeatedPassword = newPassRepeatController.text;

    if (newPassword.isEmpty || repeatedPassword.isEmpty) {
      errorRepitPass?.value = 'Las contraseñas no pueden estar vacías';
      update();
      return false;
    }

    if (newPassword == repeatedPassword) {
      errorRepitPass?.value = '';
      update();
      return true;
    } else {
      errorRepitPass?.value = 'Las contraseñas no coinciden';
      update();
      return false;
    }
  }

  /// Seleccionar tipo de comercio
  void selectTypeComerce(TypeComerceModel model) {
    comerceModelSelected = model;
    update();
  }

  /// Tomar/Seleccionar imagen para registro
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

  /// Registro de comercio
  Future<void> registerCommerce() async {
    try {
      isRegistering.value = true;
      update();

      if (comerceModelSelected == null) {
        Get.snackbar(
          'Error',
          'Debes seleccionar un tipo de comercio',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isRegistering.value = false;
        update();
        return;
      }

      var urlPhoto = await UploadFileUsesCase().execute(toSend);
      var responseCommerce = await RegisterCommerceUsescase().execute(
        photo: urlPhoto,
        email: newEmailController.text,
        name: newNameController.text,
        phone: newPhoneController.text,
        password: newPasswordController.text,
        role: comerceModelSelected!.code,
      );

      isRegistering.value = false;
      Get.dialog(
        const SuccesRegisterPage(),
        barrierDismissible: false,
      );
      _clearRegisterFields();
      update();
    } catch (e) {
      isRegistering.value = false;
      debugPrint('Error en registro: $e');
      Get.snackbar(
        'Error en registro',
        'No se pudo completar el registro. Inténtalo de nuevo.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      update();
    }
  }

  /// Limpia los campos de registro
  void _clearRegisterFields() {
    newPasswordController.clear();
    newEmailController.clear();
    newNameController.clear();
    newPhoneController.clear();
    fileTaked = null;
    comerceModelSelected = null;
    errorTextName.value = '';
    errorTextPhone.value = '';
  }

  /// Verificar email para recuperación de contraseña
  Future<void> verifyEmailUser() async {
    try {
      await ChangePasswordUseCase().execute(
        ChangePasswordParams(
          emailRecovery: emailRecoveryController.text,
        ),
      );
      errorEmailRecovery.value = '';
      pageValidation.value = 1;
      update();
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 404) {
          errorEmailRecovery.value = 'Este usuario no se encuentra registrado';
        }
      }
      update();
    }
  }

  /// Validar código OTP para recuperación
  Future<void> validateCodeOtp() async {
    try {
      await ChangePasswordUseCase().execute(
        ChangePasswordParams(
          emailRecovery: emailRecoveryController.text,
          code: int.tryParse(codeRecoveryController.text),
        ),
      );
      pageValidation.value = 2;
      update();
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 409) {
          errorCodeRecovery.value = 'Código inválido';
        }
      }
      update();
    }
  }

  /// Cambiar contraseña
  Future<void> changePassword() async {
    try {
      await ChangePasswordUseCase().execute(
        ChangePasswordParams(
          emailRecovery: emailRecoveryController.text,
          code: int.tryParse(codeRecoveryController.text),
          newPassword: newPassRecoveryController.text,
        ),
      );
      _clearRecoveryFields();
      pageValidation.value = 0;
      Get.dialog(
        const SuccesRegisterPage(
          title: '¡Tu contraseña se cambió con éxito!',
          message: '',
          postData: 'Regresa siempre que olvides tu contraseña',
        ),
        barrierDismissible: false,
      );
      update();
    } catch (e) {
      debugPrint('Error al cambiar contraseña: $e');
      rethrow;
    }
  }

  /// Limpia los campos de recuperación
  void _clearRecoveryFields() {
    emailRecoveryController.clear();
    codeRecoveryController.clear();
    newPassRecoveryController.clear();
    repeatPassRecoveryController.clear();
    errorEmailRecovery.value = '';
    errorCodeRecovery.value = '';
    errorPasswordRecovery.value = '';
  }

  /// Autentica usuario con credenciales tradicionales
  Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      _setCurrentAction(AuthAction.loginTraditional);
      _setLoading(true);
      _clearError();

      final credentials = LoginCredentials(email: email, password: password);
      final user = await _loginWithCredentialsUseCase.execute(credentials);

      // Guardar token de forma segura
      await _secureStorage.write(key: _tokenKey, value: user.accessToken);
      API.setAccessToken(user.accessToken);

      // Guardar usuario de forma segura
      await _secureStorage.write(key: _userKey, value: json.encode(user.toMap()));

      _setAuthenticatedUser(user);

      debugPrint('Login tradicional exitoso - Token guardado');

      Get.offAllNamed(PURoutes.HOME);
    } catch (e) {
      debugPrint('Error en login tradicional: $e');
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Autentica usuario con Google Sign-In
  Future<void> loginWithGoogle() async {
    try {
      isLoggingGoogle.value = true;
      _setCurrentAction(AuthAction.loginGoogle);
      _setLoading(true);
      _clearError();

      debugPrint('🔐 Iniciando Google Sign-In unificado...');
      
      // El caso de uso maneja todo el flujo: Google Auth -> Firebase -> Backend
      final user = await _loginWithSocialUseCase.executeWithGoogle();

      _setAuthenticatedUser(user);
      debugPrint('✅ Login con Google exitoso y sincronizado');

      Get.offAllNamed(PURoutes.HOME);
    } catch (e) {
      debugPrint('Error en login con Google: $e');
      _setError(_getErrorMessage(e));
      
      // Mostrar error amigable al usuario
      Get.snackbar(
        'Error',
        'No se pudo iniciar sesión con Google. Inténtalo de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoggingGoogle.value = false;
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Autentica usuario con Apple Sign-In
  Future<void> loginWithApple() async {
    try {
      _setCurrentAction(AuthAction.loginApple);
      _setLoading(true);
      _clearError();

      debugPrint('🔐 Iniciando Apple Sign-In unificado...');
      
      // El caso de uso maneja todo el flujo: Apple Auth -> Firebase -> Backend
      final user = await _loginWithSocialUseCase.executeWithApple();

      _setAuthenticatedUser(user);
      debugPrint('✅ Login con Apple exitoso');

      Get.offAllNamed(PURoutes.HOME);
    } catch (e) {
      debugPrint('Error en login con Apple: $e');
      _setError(_getErrorMessage(e));
      
      Get.snackbar(
        'Error',
        'No se pudo iniciar sesión con Apple. Inténtalo de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Cierra la sesión del usuario actual
  Future<void> logout() async {
    try {
      _setCurrentAction(AuthAction.logout);
      _setLoading(true);
      _clearError();

      await _logoutUseCase.execute();

      // Logout de Firebase si está autenticado
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (e) {
        debugPrint('Error al cerrar sesión de Firebase: $e');
      }

      await _clearSavedToken();

      // Limpiar datos de otros controladores
      if (Get.isRegistered<DinningController>()) {
        Get.find<DinningController>().clearData();
      }

      _setUnauthenticated();
      debugPrint('Logout exitoso - Token y datos limpiados');

      Get.offAllNamed(PURoutes.LOGIN);
    } catch (e) {
      debugPrint('Error en logout: $e');

      await _logoutUseCase.executeForced();
      await _clearSavedToken();
      _setUnauthenticated();

      _setError('Sesión cerrada con advertencias');
      Get.offAllNamed(PURoutes.LOGIN);
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Refresca el token del usuario actual
  Future<void> refreshUserToken() async {
    if (!isAuthenticated) return;

    try {
      _setCurrentAction(AuthAction.refreshingToken);

      final refreshedUser = await _getCurrentUserUseCase.executeWithRefresh();

      if (refreshedUser != null) {
        _setAuthenticatedUser(refreshedUser);
        debugPrint('Token refrescado exitosamente');
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('Error al refrescar token: $e');
      await logout();
    } finally {
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Verifica si el usuario tiene un rol específico
  bool hasRole(String role) {
    return currentUser?.role == role;
  }

  /// Verifica si el usuario tiene cualquiera de los roles especificados
  bool hasAnyRole(List<String> roles) {
    final userRole = currentUser?.role;
    return userRole != null && roles.contains(userRole);
  }

  /// Obtiene el nombre completo del usuario
  String get userDisplayName {
    final user = currentUser;
    if (user == null) return '';

    if (user.name.isNotEmpty) return user.name;
    if (user.email.isNotEmpty) return user.email.split('@').first;
    return 'Usuario';
  }

  /// Obtiene la URL de la foto de perfil
  String get userPhotoUrl {
    return currentUser?.photoURL ?? '';
  }

  /// Carga el token guardado desde secure storage
  Future<String?> _loadSavedToken() async {
    try {
      final savedToken = await _secureStorage.read(key: _tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        API.setAccessToken(savedToken);
        debugPrint('Token cargado desde secure storage');
        return savedToken;
      } else {
        debugPrint('No hay token guardado en secure storage');
        return null;
      }
    } catch (e) {
      debugPrint('Error al cargar token desde secure storage: $e');
      return null;
    }
  }

  /// Limpia el token guardado de secure storage
  Future<void> _clearSavedToken() async {
    try {
      API.setAccessToken('');
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
      debugPrint('Token limpiado de secure storage');
    } catch (e) {
      debugPrint('Error al limpiar token de secure storage: $e');
    }
  }

  // Métodos privados para manejo de estado

  void _setAuthenticatedUser(AuthenticatedUser user) {
    _currentUser.value = user;
    _authState.value = AuthState.authenticated;
    _clearError();
  }

  void _setUnauthenticated() {
    _currentUser.value = null;
    _authState.value = AuthState.unauthenticated;
    _clearError();
  }

  void _setLoading(bool loading) {
    _isProcessing.value = loading;
    if (loading) {
      _authState.value = AuthState.loading;
    }
  }

  void _setCurrentAction(AuthAction action) {
    _currentAction.value = action;
  }

  void _setError(String message) {
    _errorMessage.value = message;
    _authState.value = AuthState.error;
  }

  void _clearError() {
    _errorMessage.value = '';
  }

  /// Convierte excepciones a mensajes amigables para el usuario
  String _getErrorMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is AuthException) {
      switch (error.code) {
        case 'sign_in_canceled':
          return 'Autenticación cancelada por el usuario';
        case 'unauthorized':
          return 'Credenciales incorrectas';
        case 'forbidden':
          return 'No tienes permisos para acceder';
        case 'not_found':
          return 'Usuario no encontrado';
        case 'conflict':
          return 'Ya existe una cuenta con este email';
        case 'rate_limit':
          return 'Demasiados intentos. Intenta más tarde';
        default:
          return error.message;
      }
    } else if (error is NetworkException) {
      return 'Error de conexión. Verifica tu internet';
    } else {
      return 'Ha ocurrido un error inesperado';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    newEmailController.dispose();
    newNameController.dispose();
    newPhoneController.dispose();
    newPasswordController.dispose();
    emailRecoveryController.dispose();
    codeRecoveryController.dispose();
    newPassRecoveryController.dispose();
    repeatPassRecoveryController.dispose();
    newPassController.dispose();
    newPassRepeatController.dispose();
    super.onClose();
  }
}
