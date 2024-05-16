import 'dart:convert';

import 'package:pickmeup_dashboard/features/login/data/repository/login_repository.dart';
import 'package:pickmeup_dashboard/features/login/model/user_succes_model.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

import '../../../../core/exceptions/api_exception.dart';

class LoginProvider extends LoginRepository {
  @override
  Future<UserSuccess> loginCommerce({
    required String email,
    required String password,
  }) async {
    try {
      Uri loginURl = Uri.parse('$URL_PICKME_API/auth/login');
      var login = await http.post(
        loginURl,
        body: {
          "email": email,
          "password": password,
        },
      );
      var respJson = jsonDecode(login.body);
      if (respJson['access_token'] == null) {
        throw ApiException(
          respJson['statusCode'],
          respJson['message'],
        );
      }
      return UserSuccess(
        accessToken: respJson['access_token'],
        needToChangePassword: respJson['needToChangePassword'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
