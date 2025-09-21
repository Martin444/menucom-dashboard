import 'package:pickmeup_dashboard/core/helpers/image_size_helper.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/by_feature/auth/login/data/usescase/login_usescase.dart';
import 'package:menu_dart_api/by_feature/upload_images/data/usescases/upload_file_usescases.dart';
import 'package:menu_dart_api/by_feature/auth/social_login/data/usecase/social_login_usecase.dart';
import 'package:menu_dart_api/core/exeptions/api_exception.dart';
import 'package:pickmeup_dashboard/core/functions/mc_functions.dart';
import 'package:pickmeup_dashboard/features/auth/config/firebase_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu_dart_api/by_feature/user/change_password/data/usecase/change_password_usescase.dart';
import 'package:menu_dart_api/by_feature/auth/register/data/usescase/register_commerce_usescase.dart';
import 'package:menu_dart_api/by_feature/user/change_password/model/change_password_params.dart';
import 'package:menu_dart_api/core/type_comerce_model.dart';
import 'package:menu_dart_api/by_feature/auth/login/model/user_succes_model.dart';
import 'package:pickmeup_dashboard/features/login/controllers/handles/handle_login.dart';
import 'package:pickmeup_dashboard/features/login/controllers/handles/handle_register.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/succes_register_page.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  RxString? errorTextEmail = ''.obs;
  RxString errorTextPassword = ''.obs;

  RxBool isLogging = false.obs;
  RxBool isValidInit = false.obs;

  @override
  void onInit() {
    _initVersion();
    super.onInit();
  }

  _initVersion() async {
    VERSION_APP = await McFunctions.getReleaseVersion();
    update();
  }

  Future<void> loginWithEmailandPassword() async {
    try {
      isLogging.value = true;
      update();
      if (emailController.text.isEmpty) {
        throw ApiException(
          111,
          'El email no puede estar vacío',
        );
      }

      if (passwordController.text.isEmpty) {
        throw ApiException(
          102,
          'La contraseña no puede estar vacia',
        );
      }

      var responseLogin = await LoginUserUseCase().execute(
        emailController.text,
        passwordController.text,
      );

      ACCESS_TOKEN = responseLogin.accessToken;

      var sharedToken = await _prefs;
      sharedToken.setString('acccesstoken', ACCESS_TOKEN);
      isLogging.value = false;
      Get.toNamed(PURoutes.HOME);
      // if (responseLogin.needToChangePassword) {
      //   Get.toNamed(PURoutes.CHANGE_PASSWORD);
      // } else {
      // }
      emailController.clear();
      passwordController.clear();
      errorTextEmail?.value = '';
      errorTextPassword.value = '';
      update();
    } on ApiException catch (e) {
      isLogging.value = false;
      var err = e;
      if (err.statusCode == 102) {
        errorTextEmail?.value = '';
        errorTextEmail?.refresh();
        errorTextPassword.value = e.message;
        errorTextPassword.refresh();
      }
      if (err.statusCode == 401) {
        errorTextEmail?.value = '';
        errorTextPassword.value = e.message;
        errorTextPassword.refresh();
      } else if (e.statusCode == 404) {
        errorTextPassword.value = '';

        errorTextEmail?.value = e.message;
        errorTextEmail?.refresh();
      } else if (e.statusCode == 111) {
        errorTextEmail?.value = e.message;
        errorTextEmail?.refresh();
      }
      update();
    } on ClientException catch (w) {
      HandleLogin.handleLoginError(w);
    }
  }

  RxBool validateBtnLoginUser() {
    var isEmail = PUValidators.validateEmail(emailController.text);
    if (!isEmail && emailController.text.length >= 4) {
      errorTextEmail?.value = 'Ingresa un email válido';
    } else {
      errorTextEmail?.value = '';
    }

    var validateItems = (emailController.text.isNotEmpty && passwordController.text.isNotEmpty).obs;

    isValidInit = validateItems;
    update();
    return validateItems;
  }

  TextEditingController newPassController = TextEditingController();
  TextEditingController newPassRepitController = TextEditingController();
  RxString? errorRepitPass = ''.obs;

  RxBool validateRepitePass() {
    final newPassword = newPassController.text;
    final repeatedPassword = newPassRepitController.text;

    if (newPassword.isEmpty || repeatedPassword.isEmpty) {
      // Si alguna de las contraseñas está vacía, no coinciden
      errorRepitPass?.value = 'Las contraseñas no pueden estar vacías';
      update();
      return false.obs;
    }

    if (newPassword == repeatedPassword) {
      // Las contraseñas coinciden
      errorRepitPass?.value = '';
      update();
      return true.obs;
    } else {
      // Las contraseñas no coinciden
      errorRepitPass?.value = 'Las contraseñas no coinciden';
      update();
      return false.obs;
    }
  }

  Uint8List? fileTaked;
  Uint8List toSend = Uint8List(1);

  void pickImageDirectory() async {
    final ImagePicker pickerImage = ImagePicker();
    final result = await pickerImage.pickImage(source: ImageSource.gallery);
    if (result != null) {
      final String? extension = result.name.split('.').last.toLowerCase();
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
      // Reducir imagen si es necesario
      Uint8List reducedFile = ImageSizeHelper.resizeIfNeeded(originalFile);
      toSend = reducedFile;
      fileTaked = reducedFile;
      update();
    }
  }

  //REgister comerce

  TextEditingController newemailController = TextEditingController();
  TextEditingController newnameController = TextEditingController();
  TextEditingController newphoneController = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();

  List<TypeComerceModel> listCommerceAvilable = [
    TypeComerceModel(
      id: '1',
      code: 'clothes',
      description: 'Venta de ropa',
    ),
    TypeComerceModel(
      id: '2',
      code: 'dinning',
      description: 'Venta de comida',
    ),
  ];

  TypeComerceModel? comerceModelSelected;

  void selectTypeComerce(TypeComerceModel model) {
    comerceModelSelected = model;
    update();
  }

  Future<UserSuccess?> registerCommerce() async {
    try {
      isLogging.value = true;
      update();
      var urlPhoto = await UploadFileUsesCase().execute(toSend);
      var responseCommerce = await RegisterCommerceUsescase().execute(
        photo: urlPhoto,
        email: newemailController.text,
        name: newnameController.text,
        phone: newphoneController.text,
        password: newpasswordController.text,
        role: comerceModelSelected!.code,
      );

      isLogging.value = false;
      // ACCESS_TOKEN = responseCommerce.accessToken;
      // var sharedToken = await _prefs;
      // sharedToken.setString('acccesstoken', ACCESS_TOKEN);
      update();
      Get.dialog(
        const SuccesRegisterPage(),
        barrierDismissible: false,
      );
      newpasswordController.clear();
      newemailController.clear();
      newnameController.clear();
      newphoneController.clear();
      return responseCommerce;
    } catch (e) {
      isLogging.value = false;
      update();
      HandleRegister.registerError(e.toString());
    }
    return null;
  }

  //Change password

  TextEditingController emailRecoveryController = TextEditingController();
  String errorEmailRecovery = '';
  TextEditingController codeRecoveryController = TextEditingController();
  String errorCodeRecovery = '';
  TextEditingController newPassRecoveryController = TextEditingController();
  String errorPasswordRecovery = '';
  TextEditingController repeatPassRecoveryController = TextEditingController();

  int pageValidation = 0;

  void verifyEmailUser() async {
    try {
      await ChangePasswordUseCase().execute(
        ChangePasswordParams(
          emailRecovery: emailRecoveryController.text,
        ),
      );
      errorEmailRecovery = '';
      pageValidation = 1;
      update();
    } catch (e) {
      if (e.runtimeType == ApiException) {
        var err = (e as ApiException);
        if (err.statusCode == 404) {
          errorEmailRecovery = 'Este usuario no se encuentra registrado';
        }
      }
      update();
    }
  }

  void validateCodeOtp() async {
    try {
      await ChangePasswordUseCase().execute(
        ChangePasswordParams(
          emailRecovery: emailRecoveryController.text,
          code: int.tryParse(codeRecoveryController.text),
        ),
      );
      pageValidation = 2;
      update();
    } catch (e) {
      if (e.runtimeType == ApiException) {
        var err = (e as ApiException);
        if (err.statusCode == 409) {
          errorCodeRecovery = 'Código invalido';
        }
      }
      update();
    }
  }

  void changePassword() async {
    try {
      await ChangePasswordUseCase().execute(
        ChangePasswordParams(
          emailRecovery: emailRecoveryController.text,
          code: int.tryParse(codeRecoveryController.text),
          newPassword: newPassRecoveryController.text,
        ),
      );
      emailRecoveryController.clear();
      codeRecoveryController.clear();
      newPassRecoveryController.clear();
      pageValidation = 0;
      errorEmailRecovery = '';
      errorCodeRecovery = '';
      Get.dialog(
        const SuccesRegisterPage(
          title: '¡Tu contraseña se cambió con exito!',
          message: '',
          postData: 'Regresa siempre que olvides tu contraseña',
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Autentica usuario con Google Sign-In
  Future<void> loginWithGoogle() async {
    try {
      isLogging.value = true;
      update();

      // Inicializar Google Sign-In con configuración específica
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: FirebaseConfig.googleSignInClientId,
      );

      // Realizar el sign-in con Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el sign-in
        isLogging.value = false;
        update();
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
        // Obtener el token de Firebase para usar con tu API
        final String? firebaseToken = await user.getIdToken();

        if (firebaseToken != null) {
          try {
            debugPrint('🔐 Iniciando autenticación social con backend...');

            // Usar SocialLoginUseCase para autenticar con el backend
            final socialLoginUseCase = SocialLoginUseCase();
            final socialLoginResponse = await socialLoginUseCase.execute(
              firebaseIdToken: firebaseToken,
              additionalData: {
                'email': user.email,
                'name': user.displayName,
                'photoURL': user.photoURL,
                'provider': 'google',
              },
            );

            debugPrint('✅ Autenticación social exitosa');
            debugPrint('📧 Usuario: ${user.email}');

            // Usar el token de acceso del backend (no el de Firebase)
            ACCESS_TOKEN = socialLoginResponse.accessToken;

            var sharedToken = await _prefs;
            sharedToken.setString('acccesstoken', ACCESS_TOKEN);

            isLogging.value = false;
            Get.toNamed(PURoutes.HOME);
            update();
          } catch (e) {
            isLogging.value = false;
            update();
            debugPrint('❌ Error en autenticación con backend: $e');

            String errorMessage = 'Error al autenticar con el servidor.';
            if (e is ApiException) {
              errorMessage = e.message;
            }

            Get.snackbar(
              'Error de Autenticación',
              '$errorMessage Inténtalo de nuevo.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          }
        } else {
          isLogging.value = false;
          update();
          debugPrint('❌ No se pudo obtener el token de Firebase');
          Get.snackbar(
            'Error',
            'No se pudo obtener el token de autenticación.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      isLogging.value = false;
      update();
      debugPrint('Error en login con Google: $e');
      // Aquí puedes manejar el error según tus necesidades
      Get.snackbar(
        'Error',
        'No se pudo iniciar sesión con Google. Inténtalo de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
