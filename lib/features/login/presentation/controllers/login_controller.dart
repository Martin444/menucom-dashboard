import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickmeup_dashboard/core/functions/mc_functions.dart';
import 'package:pickmeup_dashboard/features/login/data/usecase/change_password_usescase.dart';
import 'package:pickmeup_dashboard/features/login/data/usecase/register_commerce_usescase.dart';
import 'package:pickmeup_dashboard/features/login/model/user_succes_model.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config.dart';
import '../../../../core/exceptions/api_exception.dart';
import '../../../home/data/usescases/upload_file_usescases.dart';
import '../../data/usecase/login_usescase.dart';

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

      var responseLogin = await LoginUserUseCase().execute(
        emailController.text,
        passwordController.text,
      );
      ACCESS_TOKEN = responseLogin.accessToken;

      var sharedToken = await _prefs;
      sharedToken.setString('acccesstoken', ACCESS_TOKEN);
      isLogging.value = false;
      if (responseLogin.needToChangePassword) {
        Get.toNamed(PURoutes.CHANGE_PASSWORD);
      } else {
        Get.toNamed(PURoutes.HOME);
      }
      emailController.clear();
      passwordController.clear();
      errorTextEmail?.value = '';
      errorTextPassword.value = '';
      update();
    } on ApiException catch (e) {
      print(e);
      isLogging.value = false;
      if (e.statusCode == 401) {
        errorTextEmail?.value = '';
        errorTextPassword.value = e.message;
        errorTextPassword.refresh();
      } else if (e.statusCode == 404) {
        errorTextEmail?.value = e.message;
        errorTextEmail?.refresh();
      }
      update();
    }
  }

  RxBool validateBtnLoginUser() {
    var isEmail = PUValidators.validateEmail(emailController.text);
    if (!isEmail && emailController.text.length >= 4) {
      errorTextEmail?.value = 'Ingresa un email válido';
    } else {
      errorTextEmail?.value = '';
    }

    var validateItems =
        (emailController.text.isNotEmpty && passwordController.text.isNotEmpty)
            .obs;

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

  Future<void> changePasswordCommerce() async {
    try {
      var responsePass = await ChangePasswordUseCase().execute(
        newPassRepitController.text,
      );
      if (responsePass) {
        errorRepitPass?.value = '';
        Get.toNamed(PURoutes.LOGIN);
      }
      return;
    } catch (e) {
      rethrow;
    }
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

  //REgister comerce

  TextEditingController newemailController = TextEditingController();
  TextEditingController newnameController = TextEditingController();
  TextEditingController newphoneController = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();

  Future<UserSuccess> registerCommerce() async {
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
      );

      isLogging.value = false;
      ACCESS_TOKEN = responseCommerce.accessToken;
      var sharedToken = await _prefs;
      sharedToken.setString('acccesstoken', ACCESS_TOKEN);
      update();
      Get.toNamed(PURoutes.REGISTER_ITEM_MENU);
      newpasswordController.clear();
      newemailController.clear();
      newnameController.clear();
      newphoneController.clear();
      return responseCommerce;
    } catch (e) {
      rethrow;
    }
  }
}
