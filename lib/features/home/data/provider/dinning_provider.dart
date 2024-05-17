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
      var respJson = jsonDecode(response.body);

      if (respJson['id'] == null) {
        throw ApiException(
          respJson['statusCode'],
          respJson['message'],
        );
      }
      return DinningModel.fromJson(respJson);
    } catch (e) {
      rethrow;
    }
  }
}
