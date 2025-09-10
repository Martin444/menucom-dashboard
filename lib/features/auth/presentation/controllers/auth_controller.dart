import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/entities/auth_params.dart';
import '../../domain/usecases/login_with_credentials_usecase.dart';
import '../../domain/usecases/login_with_social_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../config/firebase_config.dart';
import '../../../../core/config.dart'; // Para usar ACCESS_TOKEN global

/// Estados posibles de la autenticación
enum AuthState {
  initial, // Estado inicial
  loading, // Procesando autenticación
  authenticated, // Usuario autenticado
  unauthenticated, // Usuario no autenticado
  error, // Error en el proceso
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
}

/// Controlador principal para el manejo de autenticación.
///
/// Este controlador centraliza toda la lógica de autenticación del dashboard,
/// incluyendo login tradicional, social, logout y gestión de estado.
class AuthController extends GetxController {
  // Casos de uso
  late final LoginWithCredentialsUseCase _loginWithCredentialsUseCase;
  late final LoginWithSocialUseCase _loginWithSocialUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  // SharedPreferences para persistencia de token
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Estado reactivo
  final Rx<AuthState> _authState = AuthState.initial.obs;
  final Rx<AuthAction> _currentAction = AuthAction.none.obs;
  final Rx<AuthenticatedUser?> _currentUser = Rx<AuthenticatedUser?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isProcessing = false.obs;

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
    await _checkAuthenticationStatus();
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
  Future<void> _checkAuthenticationStatus() async {
    try {
      _setCurrentAction(AuthAction.checkingAuth);
      _setLoading(true);

      // Cargar el token guardado de SharedPreferences
      await _loadSavedToken();

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

  /// Autentica usuario con credenciales tradicionales (email/password) y guarda el token
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

      // Guardar el ACCESS_TOKEN como lo hace login_controller
      ACCESS_TOKEN = user.accessToken;
      var sharedToken = await _prefs;
      sharedToken.setString('acccesstoken', ACCESS_TOKEN);

      _setAuthenticatedUser(user);
      debugPrint('Login tradicional exitoso - Token guardado');

      // Navegar al dashboard principal
      Get.offAllNamed('/dashboard');
    } catch (e) {
      debugPrint('Error en login tradicional: $e');
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Autentica usuario con Google Sign-In y guarda el token
  Future<void> loginWithGoogle() async {
    try {
      _setCurrentAction(AuthAction.loginGoogle);
      _setLoading(true);
      _clearError();

      // Inicializar Google Sign-In con configuración específica
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: FirebaseConfig.googleSignInClientId,
      );

      // Realizar el sign-in con Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el sign-in
        debugPrint('Login con Google cancelado por el usuario');
        return;
      }

      // Obtener las credenciales de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear credenciales para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Autenticar con Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Obtener el token de Firebase
        final String? firebaseToken = await user.getIdToken();

        if (firebaseToken != null) {
          // TODO: Llamar al endpoint de social login del API aquí
          // Por ahora, guardamos el token de Firebase como el ACCESS_TOKEN
          ACCESS_TOKEN = firebaseToken;
          var sharedToken = await _prefs;
          sharedToken.setString('acccesstoken', ACCESS_TOKEN);

          // Crear el usuario autenticado con los datos disponibles
          final authenticatedUser = AuthenticatedUser(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            role: 'user', // Rol por defecto, se actualizará con la respuesta del API
            accessToken: firebaseToken,
            needToChangePassword: false,
            isEmailVerified: user.emailVerified,
            photoURL: user.photoURL,
            socialToken: firebaseToken,
            firebaseProvider: 'google.com',
          );

          _setAuthenticatedUser(authenticatedUser);
          debugPrint('Login con Google exitoso - Token guardado');

          // Navegar al dashboard principal
          Get.offAllNamed('/dashboard');
        } else {
          throw Exception('No se pudo obtener el token de Firebase');
        }
      } else {
        throw Exception('No se pudo autenticar con Firebase');
      }
    } catch (e) {
      debugPrint('Error en login con Google: $e');
      _setError(_getErrorMessage(e));
    } finally {
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

      final user = await _loginWithSocialUseCase.executeWithApple();

      _setAuthenticatedUser(user);
      debugPrint('Login con Apple exitoso');

      // Navegar al dashboard principal
      Get.offAllNamed('/dashboard');
    } catch (e) {
      debugPrint('Error en login con Apple: $e');
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
      _setCurrentAction(AuthAction.none);
    }
  }

  /// Cierra la sesión del usuario actual y limpia los tokens
  Future<void> logout() async {
    try {
      _setCurrentAction(AuthAction.logout);
      _setLoading(true);
      _clearError();

      await _logoutUseCase.execute();

      // Limpiar el token guardado
      await _clearSavedToken();

      _setUnauthenticated();
      debugPrint('Logout exitoso - Token limpiado');

      // Navegar a la pantalla de login
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Error en logout: $e');

      // Realizar logout forzado en caso de error
      await _logoutUseCase.executeForced();
      await _clearSavedToken();
      _setUnauthenticated();

      _setError('Sesión cerrada con advertencias');
      Get.offAllNamed('/login');
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
        // Si no se puede refrescar, cerrar sesión
        await logout();
      }
    } catch (e) {
      debugPrint('Error al refrescar token: $e');
      // En caso de error, cerrar sesión
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

  /// Obtiene el nombre completo del usuario para mostrar en la UI
  String get userDisplayName {
    final user = currentUser;
    if (user == null) return '';

    if (user.name.isNotEmpty) return user.name;
    if (user.email.isNotEmpty) return user.email.split('@').first;
    return 'Usuario';
  }

  /// Obtiene la URL de la foto de perfil o un placeholder
  String get userPhotoUrl {
    return currentUser?.photoURL ?? '';
  }

  /// Carga el token guardado desde SharedPreferences
  Future<void> _loadSavedToken() async {
    try {
      var sharedPrefs = await _prefs;
      final savedToken = sharedPrefs.getString('acccesstoken');
      if (savedToken != null && savedToken.isNotEmpty) {
        ACCESS_TOKEN = savedToken;
        debugPrint('Token cargado desde SharedPreferences');
      } else {
        debugPrint('No hay token guardado en SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error al cargar token desde SharedPreferences: $e');
    }
  }

  /// Limpia el token guardado de SharedPreferences
  Future<void> _clearSavedToken() async {
    try {
      ACCESS_TOKEN = '';
      var sharedPrefs = await _prefs;
      await sharedPrefs.remove('acccesstoken');
      debugPrint('Token limpiado de SharedPreferences');
    } catch (e) {
      debugPrint('Error al limpiar token de SharedPreferences: $e');
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
    // Limpiar recursos si es necesario
    super.onClose();
  }
}
