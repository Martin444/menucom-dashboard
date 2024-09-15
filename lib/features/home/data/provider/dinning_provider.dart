import 'dart:convert';

import 'package:pickmeup_dashboard/features/home/data/repository/dinning_repository.dart';
import 'package:http/http.dart' as http;
import 'package:pickmeup_dashboard/features/home/models/dinning_model.dart';

import '../../../../core/config.dart';
import '../../../../core/exceptions/api_exception.dart';

class DinningProvider extends DinningRepository {
  @override
  Future<DinningModel> getMe() async {
    try {
      Uri userURl = Uri.parse('$URL_PICKME_API/user/me');
      var response = await http.get(
        headers: {'Authorization': 'Bearer $ACCESS_TOKEN'},
        userURl,
      );
      if (response.statusCode != 200) {
        throw ApiException(
          response.statusCode,
          response.body,
        );
      }
      var respJson = jsonDecode(response.body);

      return DinningModel.fromJson(respJson);
    } catch (e) {
      rethrow;
    }
  }
}
