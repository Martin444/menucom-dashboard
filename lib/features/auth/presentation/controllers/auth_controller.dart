import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/by_feature/user/change_password/data/usecase/change_password_usescase.dart';
import 'package:menu_dart_api/by_feature/auth/register/data/usescase/register_commerce_usecase.dart';
import 'package:menu_dart_api/core/type_commerce_model.dart';
import 'package:menu_dart_api/by_feature/user/change_password/model/change_password_params.dart';
import 'package:menu_dart_api/by_feature/auth/login/data/usescase/login_usescase.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/succes_register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../data/datasources/auth_firebase_datasource.dart';
import '../../../../core/config.dart';
import '../../../../core/functions/mc_functions.dart';
import 'package:pickmeup_dashboard/core/helpers/image_size_helper.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/core/fcm_util.dart';
import 'package:pickmeup_dashboard/core/analytics_service.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:menu_dart_api/menu_com_api.dart' hide ValidationException;

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

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

class AuthController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'authenticated_user';

  final Rx<AuthState> _authState = AuthState.initial.obs;
  final Rx<AuthAction> _currentAction = AuthAction.none.obs;
  final Rx<AuthenticatedUser?> _currentUser = Rx<AuthenticatedUser?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isProcessing = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController newNameController = TextEditingController();
  final TextEditingController newPhoneController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  final TextEditingController emailRecoveryController = TextEditingController();
  final TextEditingController codeRecoveryController = TextEditingController();
  final TextEditingController newPassRecoveryController = TextEditingController();
  final TextEditingController repeatPassRecoveryController = TextEditingController();

  final TextEditingController newPassController = TextEditingController();
  final TextEditingController newPassRepeatController = TextEditingController();

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
  final RxBool isLoadingImage = false.obs;
  final RxBool isValidInit = false.obs;
  final RxInt pageValidation = 0.obs;

  Uint8List? fileTaked;
  Uint8List toSend = Uint8List(1);
  TypeCommerceModel? commerceModelSelected;
  List<TypeCommerceModel> listCommerceAvailable = TypeCommerceModel.getAvailableCommerceTypes();

  AuthFirebaseDataSource? _firebaseDataSource;

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
    _firebaseDataSource = AuthFirebaseDataSourceFactory.create();
    await checkAuthenticationStatus();
    _initVersion();
  }

  void _initVersion() async {
    VERSION_APP = await McFunctions.getReleaseVersion();
    update();
  }

  Future<void> checkAuthenticationStatus() async {
    if (isAuthenticated && authState == AuthState.authenticated) {
      debugPrint('Salteando checkAuthenticationStatus: ya autenticado');
      return;
    }

    try {
      _setCurrentAction(AuthAction.checkingAuth);
      _setLoading(true);

      final token = await _loadSavedToken();
      if (token == null || token.isEmpty) {
        _setUnauthenticated(clearApiToken: API.loginAccessToken.isEmpty);
        return;
      }

      final savedUserJson = await _secureStorage.read(key: _userKey);
      if (savedUserJson != null) {
        final savedUserMap = json.decode(savedUserJson) as Map<String, dynamic>;
        savedUserMap['accessToken'] = token;
        final savedUser = AuthenticatedUser.fromMap(savedUserMap);
        _setAuthenticatedUser(savedUser);

        try {
          final refreshResponse = await RefreshTokenUseCase().execute();
          final updatedUser = savedUser.copyWith(
            accessToken: refreshResponse.accessToken,
          );
          _setAuthenticatedUser(updatedUser);
          await _secureStorage.write(key: _userKey, value: json.encode(updatedUser.toMap()));
          debugPrint('Token refrescado al iniciar app');
        } catch (_) {
          debugPrint('No se pudo refrescar token al inicio, usando token guardado');
        }
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      debugPrint('Error al verificar estado de autenticacion: $e');
      _setUnauthenticated();
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  Future<void> loginWithEmailAndPassword() async {
    try {
      isLogging.value = true;
      _setCurrentAction(AuthAction.loginTraditional);
      _clearError();
      update();

      if (emailController.text.isEmpty) {
        throw const ValidationException('El email no puede estar vacio');
      }

      if (passwordController.text.isEmpty) {
        throw const ValidationException('La contrasenia no puede estar vacia');
      }

      final userSuccess = await LoginUserUseCase().execute(
        emailController.text,
        passwordController.text,
      );

      API.setAccessToken(userSuccess.accessToken);
      await _secureStorage.write(key: _tokenKey, value: userSuccess.accessToken);

      AuthenticatedUser authUser;
      try {
        final dinning = await GetDinningUseCase().execute();
        authUser = AuthenticatedUser(
          id: dinning.id ?? '',
          email: dinning.email ?? emailController.text,
          name: dinning.name ?? '',
          photoURL: dinning.photoURL,
          phone: dinning.phone,
          role: dinning.role ?? 'customer',
          accessToken: userSuccess.accessToken,
          needToChangePassword: userSuccess.needToChangePassword,
          isEmailVerified: dinning.isEmailVerified,
        );
      } catch (_) {
        authUser = AuthenticatedUser(
          id: '',
          email: emailController.text,
          name: '',
          role: 'customer',
          accessToken: userSuccess.accessToken,
          needToChangePassword: userSuccess.needToChangePassword,
          isEmailVerified: false,
        );
      }

      await _secureStorage.write(key: _userKey, value: json.encode(authUser.toMap()));
      _setAuthenticatedUser(authUser);

      debugPrint('Login tradicional exitoso para: ${authUser.email}');
      AnalyticsService().logLogin(method: 'email');
      AnalyticsService().setUserId(authUser.id.toString());

      isLogging.value = false;
      _setCurrentAction(AuthAction.none);
      _clearLoginFields();
      update();

      Get.offAllNamed(PURoutes.HOME);
    } catch (e) {
      isLogging.value = false;
      _setCurrentAction(AuthAction.none);
      debugPrint('Error en login con email/password: $e');

      if (e is ValidationException) {
        if (e.message.contains('email')) {
          errorTextEmail.value = e.message;
        } else if (e.message.contains('contrasenia') || e.message.contains('password')) {
          errorTextPassword.value = e.message;
        }
        update();
        return;
      }

      if (e is ApiException) {
        if (e.statusCode == 401) {
          errorTextPassword.value = e.message.isNotEmpty ? e.message : 'Credenciales incorrectas';
          update();
          return;
        } else if (e.statusCode == 404) {
          errorTextEmail.value = e.message.isNotEmpty ? e.message : 'No se encontro el usuario';
          update();
          return;
        }
      }

      final errorMsg = _getErrorMessage(e);
      AnalyticsService().logError(errorMsg, context: 'login_email_error');
      Get.snackbar(
        'Error al Iniciar sesion',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      update();
    }
  }

  void _clearLoginFields() {
    emailController.clear();
    passwordController.clear();
    errorTextEmail.value = '';
    errorTextPassword.value = '';
  }

  bool validateBtnLoginUser() {
    var isEmail = _isValidEmail(emailController.text);
    if (!isEmail && emailController.text.length >= 4) {
      errorTextEmail.value = 'Ingresa un email valido';
    } else {
      errorTextEmail.value = '';
    }

    var validateItems = (emailController.text.isNotEmpty && passwordController.text.isNotEmpty);
    isValidInit.value = validateItems;
    update();
    return validateItems;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool validateRepeatPass() {
    final newPassword = newPassController.text;
    final repeatedPassword = newPassRepeatController.text;

    if (newPassword.isEmpty || repeatedPassword.isEmpty) {
      errorRepitPass?.value = 'Las contrasenias no pueden estar vacias';
      update();
      return false;
    }

    if (newPassword == repeatedPassword) {
      errorRepitPass?.value = '';
      update();
      return true;
    } else {
      errorRepitPass?.value = 'Las contrasenias no coinciden';
      update();
      return false;
    }
  }

  void selectTypeComerce(TypeCommerceModel model) {
    commerceModelSelected = model;
    update();
  }

  void pickImageDirectory() async {
    isLoadingImage.value = true;
    update();
    try {
      final ImagePicker pickerImage = ImagePicker();
      final result = await pickerImage.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      if (result != null) {
        final String extension = result.name.split('.').last.toLowerCase();
        if (extension != 'png' && extension != 'jpg' && extension != 'jpeg') {
          Get.snackbar(
            'Formato invalido',
            'Solo se permiten imagenes PNG o JPG.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        final Uint8List originalFile = await result.readAsBytes();
        final Uint8List reducedFile = ImageSizeHelper.resizeIfNeeded(originalFile);
        toSend = reducedFile;
        fileTaked = reducedFile;
      }
    } finally {
      isLoadingImage.value = false;
      update();
    }
  }

  Future<void> registerCommerce() async {
    try {
      isRegistering.value = true;
      update();

      if (commerceModelSelected == null) {
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

      await RegisterCommerceUseCase().execute(
        fileBytes: toSend,
        email: newEmailController.text,
        name: newNameController.text,
        phone: newPhoneController.text,
        password: newPasswordController.text,
        role: commerceModelSelected!.code,
      );

      isRegistering.value = false;
      AnalyticsService().logSignUp(method: 'email');
      Get.dialog(
        const SuccesRegisterPage(),
        barrierDismissible: false,
      );
      _clearRegisterFields();
      update();
    } catch (e) {
      isRegistering.value = false;
      debugPrint('Error en registro: $e');
      AnalyticsService().logErrorWithException(e, context: 'register_error');
      if (e is ApiException &&
          e.statusCode == 400 &&
          e.message.toLowerCase().contains('límite')) {
        GlobalDialogsHandles.showPlanLimitDialog(
          title: 'Límite de comercios alcanzado',
          message: e.message,
          onUpgradePressed: () => Get.toNamed(PURoutes.MEMBERSHIP),
        );
      } else {
        Get.snackbar(
          'Error en registro',
          'No se pudo completar el registro. Intentalo de nuevo.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      update();
    }
  }

  void _clearRegisterFields() {
    newPasswordController.clear();
    newEmailController.clear();
    newNameController.clear();
    newPhoneController.clear();
    fileTaked = null;
    commerceModelSelected = null;
    errorTextName.value = '';
    errorTextPhone.value = '';
  }

  Future<void> verifyEmailUser() async {
    try {
      await ChangePasswordUseCase().execute(
        ChangePasswordParams(emailRecovery: emailRecoveryController.text),
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
          errorCodeRecovery.value = 'Codigo invalido';
        }
      }
      update();
    }
  }

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
          title: 'Tu contrasenia se cambio con exito!',
          message: '',
          postData: 'Regresa siempre que olvides tu contrasenia',
        ),
        barrierDismissible: false,
      );
      update();
    } catch (e) {
      debugPrint('Error al cambiar contrasenia: $e');
      rethrow;
    }
  }

  void _clearRecoveryFields() {
    emailRecoveryController.clear();
    codeRecoveryController.clear();
    newPassRecoveryController.clear();
    repeatPassRecoveryController.clear();
    errorEmailRecovery.value = '';
    errorCodeRecovery.value = '';
    errorPasswordRecovery.value = '';
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoggingGoogle.value = true;
      _setCurrentAction(AuthAction.loginGoogle);
      _setLoading(true);
      _clearError();

      debugPrint('Iniciando Google Sign-In unificado...');

      final firebaseIdToken = await _firebaseDataSource!.signInWithGoogle();
      final socialResponse = await SocialLoginUseCase().execute(
        firebaseIdToken: firebaseIdToken,
      );

      final user = socialResponse.user;
      final authUser = AuthenticatedUser(
        id: user?.id ?? '',
        email: user?.email ?? '',
        name: user?.name ?? '',
        photoURL: user?.photoURL,
        phone: user?.phone,
        role: user?.role ?? 'customer',
        accessToken: socialResponse.accessToken,
        needToChangePassword: socialResponse.needToChangePassword,
        socialToken: user?.socialToken,
        firebaseProvider: user?.firebaseProvider,
        isEmailVerified: user?.isEmailVerified ?? true,
        lastLoginAt: user?.lastLoginAt,
      );

      API.setAccessToken(authUser.accessToken);
      await _secureStorage.write(key: _tokenKey, value: authUser.accessToken);
      await _secureStorage.write(key: _userKey, value: json.encode(authUser.toMap()));

      _setAuthenticatedUser(authUser);
      debugPrint('Login con Google exitoso y sincronizado');
      AnalyticsService().logLogin(method: 'google');
      AnalyticsService().setUserId(authUser.id);

      Get.offAllNamed(PURoutes.HOME);
    } catch (e) {
      debugPrint('Error en login con Google: $e');
      AnalyticsService().logErrorWithException(e, context: 'login_google_error');
      _setError(_getErrorMessage(e));

      Get.snackbar(
        'Error',
        'No se pudo iniciar sesion con Google. Intentalo de nuevo.',
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

  Future<void> loginWithApple() async {
    try {
      _setCurrentAction(AuthAction.loginApple);
      _setLoading(true);
      _clearError();

      debugPrint('Iniciando Apple Sign-In unificado...');

      final firebaseIdToken = await _firebaseDataSource!.signInWithApple();
      final socialResponse = await SocialLoginUseCase().execute(
        firebaseIdToken: firebaseIdToken,
      );

      final user = socialResponse.user;
      final authUser = AuthenticatedUser(
        id: user?.id ?? '',
        email: user?.email ?? '',
        name: user?.name ?? '',
        photoURL: user?.photoURL,
        phone: user?.phone,
        role: user?.role ?? 'customer',
        accessToken: socialResponse.accessToken,
        needToChangePassword: socialResponse.needToChangePassword,
        socialToken: user?.socialToken,
        firebaseProvider: user?.firebaseProvider,
        isEmailVerified: user?.isEmailVerified ?? true,
        lastLoginAt: user?.lastLoginAt,
      );

      API.setAccessToken(authUser.accessToken);
      await _secureStorage.write(key: _tokenKey, value: authUser.accessToken);
      await _secureStorage.write(key: _userKey, value: json.encode(authUser.toMap()));

      _setAuthenticatedUser(authUser);
      debugPrint('Login con Apple exitoso');
      AnalyticsService().logLogin(method: 'apple');
      AnalyticsService().setUserId(authUser.id);

      Get.offAllNamed(PURoutes.HOME);
    } catch (e) {
      debugPrint('Error en login con Apple: $e');
      AnalyticsService().logErrorWithException(e, context: 'login_apple_error');
      _setError(_getErrorMessage(e));

      Get.snackbar(
        'Error',
        'No se pudo iniciar sesion con Apple. Intentalo de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  Future<void> logout() async {
    try {
      _setCurrentAction(AuthAction.logout);
      _setLoading(true);
      _clearError();

      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (e) {
        debugPrint('Error al cerrar sesion de Firebase: $e');
      }

      await _clearSavedToken();

      if (Get.isRegistered<DinningController>()) {
        Get.find<DinningController>().clearData();
      }

      _setUnauthenticated();
      debugPrint('Logout exitoso - Token y datos limpiados');
      AnalyticsService().logLogout();
      AnalyticsService().setUserId(null);

      Get.offAllNamed(PURoutes.LOGIN);
    } catch (e) {
      debugPrint('Error en logout: $e');
      await _clearSavedToken();
      _setUnauthenticated();

      _setError('Sesion cerrada con advertencias');
      Get.offAllNamed(PURoutes.LOGIN);
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  Future<void> refreshUserToken() async {
    if (!isAuthenticated) return;

    try {
      _setCurrentAction(AuthAction.refreshingToken);

      final refreshResponse = await RefreshTokenUseCase().execute();
      final updatedUser = _currentUser.value!.copyWith(
        accessToken: refreshResponse.accessToken,
      );

      API.setAccessToken(refreshResponse.accessToken);
      await _secureStorage.write(key: _tokenKey, value: refreshResponse.accessToken);
      await _secureStorage.write(key: _userKey, value: json.encode(updatedUser.toMap()));

      _setAuthenticatedUser(updatedUser);
      debugPrint('Token refrescado exitosamente');
    } catch (e) {
      debugPrint('Error al refrescar token: $e');
      await logout();
    } finally {
      _setCurrentAction(AuthAction.none);
    }
  }

  bool hasRole(String role) {
    return currentUser?.role == role;
  }

  bool hasAnyRole(List<String> roles) {
    final userRole = currentUser?.role;
    return userRole != null && roles.contains(userRole);
  }

  String get userDisplayName {
    final user = currentUser;
    if (user == null) return '';
    if (user.name.isNotEmpty) return user.name;
    if (user.email.isNotEmpty) return user.email.split('@').first;
    return 'Usuario';
  }

  String get userPhotoUrl {
    return currentUser?.photoURL ?? '';
  }

  Future<String?> _loadSavedToken() async {
    try {
      if (API.loginAccessToken.isNotEmpty) {
        return API.loginAccessToken;
      }
      final savedToken = await _secureStorage.read(key: _tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        API.setAccessToken(savedToken);
        return savedToken;
      }
      return null;
    } catch (e) {
      debugPrint('Error al cargar token desde secure storage: $e');
      return null;
    }
  }

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

  void _setAuthenticatedUser(AuthenticatedUser user) {
    _currentUser.value = user;
    _authState.value = AuthState.authenticated;

    if (user.accessToken.isNotEmpty) {
      API.setAccessToken(user.accessToken);
    }

    _syncFcmToken();
    AnalyticsService().setUserId(user.id);
    AnalyticsService().setUserProperty(name: 'role', value: user.role);
    _clearError();
  }

  void _syncFcmToken() {
    setupFCM(
      onTokenReceived: (fcmToken) async {
        try {
          final updateUseCase = UpdateFcmTokenUseCase(UpdateFcmTokenProvider());
          await updateUseCase.execute(fcmToken: fcmToken);
          debugPrint('FCM Token sincronizado con el backend exitosamente');
        } catch (e) {
          debugPrint('Error al sincronizar FCM Token: $e');
        }
      },
    );
  }

  void _setUnauthenticated({bool clearApiToken = true}) {
    _currentUser.value = null;
    _authState.value = AuthState.unauthenticated;

    if (clearApiToken) {
      API.setAccessToken('');
    }

    resetFCM();
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

  String _getErrorMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is AuthException) {
      final apiMessage = error.message;
      switch (error.code) {
        case 'sign_in_canceled':
          return 'Autenticacion cancelada por el usuario';
        case 'unauthorized':
          return apiMessage.isNotEmpty ? apiMessage : 'Credenciales incorrectas';
        case 'forbidden':
          return 'No tienes permisos para acceder';
        case 'not_found':
          return apiMessage.isNotEmpty ? apiMessage : 'Usuario no encontrado';
        case 'conflict':
          return apiMessage.isNotEmpty ? apiMessage : 'Ya existe una cuenta con este email';
        case 'rate_limit':
          return 'Demasiados intentos. Intenta mas tarde';
        default:
          return apiMessage.isNotEmpty ? apiMessage : 'Error de autenticacion';
      }
    } else if (error is NetworkException) {
      return 'Error de conexion. Verifica tu internet';
    } else if (error is ApiException) {
      return error.message.isNotEmpty ? error.message : 'Error del servidor';
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
