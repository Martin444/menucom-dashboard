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
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImRpbmluZyIsInN1YiI6ImIyM2Q0MmM2LTNjNjMtNGQ2ZC1iMTMwLTUwYjIxOGM4ODAzYSIsImlhdCI6MTcyMTE4NTQzMSwiZXhwIjoxNzIxMjcxODMxfQ.AQJAqwNJnd2_PrbzSyJOF4uEP7d0ML01BmSXBfht79Y'
        },
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
