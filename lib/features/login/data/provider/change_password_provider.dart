import 'dart:convert';

import 'package:pickmeup_dashboard/features/login/data/repository/change_password_repository.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config.dart';

class ChangePasswordProvider extends ChangePasswordRepository {
  @override
  Future<bool> changePassword({required String newPass}) async {
    try {
      Uri changeURl = Uri.parse('$URL_PICKME_API/user/change-password');
      var changePassResponse = await http.post(
        changeURl,
        headers: {'Authorization': 'Bearer $ACCESS_TOKEN'},
        body: {
          "newPassword": newPass,
        },
      );

      var respJson = jsonDecode(changePassResponse.body);
      return respJson;
    } catch (e) {
      rethrow;
    }
  }
}
