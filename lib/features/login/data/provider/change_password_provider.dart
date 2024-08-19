import 'dart:convert';

import 'package:pickmeup_dashboard/core/exceptions/api_exception.dart';
import 'package:pickmeup_dashboard/features/login/data/repository/change_password_repository.dart';
import 'package:http/http.dart' as http;
import 'package:pickmeup_dashboard/features/login/model/change_password_params.dart';
import '../../../../core/config.dart';

class ChangePasswordProvider extends ChangePasswordRepository {
  @override
  Future<dynamic> changePassword({required ChangePasswordParams params}) async {
    try {
      Uri changeURl = Uri.parse('$URL_PICKME_API/user/change-password');
      var changePassResponse = await http.post(
        changeURl,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: params.toJson(),
      );
      if (changePassResponse.statusCode != 201) {
        throw ApiException(
          changePassResponse.statusCode,
          changePassResponse.body,
        );
      }

      var respJson = jsonDecode(changePassResponse.body);
      return respJson;
    } catch (e) {
      rethrow;
    }
  }
}
