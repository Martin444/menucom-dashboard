import 'dart:convert';

import 'package:pickmeup_dashboard/features/login/data/repository/register_commerce_respository.dart';
import 'package:pickmeup_dashboard/features/login/model/user_succes_model.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

import '../../../../core/exceptions/api_exception.dart';

class RegisterCommerceProvider extends RegisterCommerceRespository {
  @override
  Future<UserSuccess> registerCommerce({
    required String photo,
    required String email,
    required String name,
    required String phone,
    required String role,
    required String password,
  }) async {
    try {
      Uri loginURl = Uri.parse('$URL_PICKME_API/auth/register');
      var login = await http.post(
        loginURl,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "photoURL": photo,
          "email": email,
          "name": name,
          "phone": phone,
          "password": password,
          "role": "dining",
          "needToChangepassword": false,
        }),
      );
      var respJson = jsonDecode(login.body);
      if (respJson['access_token'] == null) {
        throw ApiException(
          respJson['statusCode'] ?? 32,
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
