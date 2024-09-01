import 'dart:convert';

import 'package:pickmeup_dashboard/core/exceptions/api_exception.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/repository/get_wardrobes_repository.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

class GetWardrobesProvider extends GetWardrobesRepository {
  @override
  Future<List<WardrobeModel>> getWardRobes() async {
    try {
      Uri wardrobeCreateURl = Uri.parse('$URL_PICKME_API/wardrobe/me');
      List<WardrobeModel> wards = [];
      var wardrobe = await http.get(
        wardrobeCreateURl,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $ACCESS_TOKEN',
        },
      );

      if (wardrobe.statusCode != 200) {
        throw ApiException(
          wardrobe.statusCode,
          wardrobe.body,
        );
      }

      final resJson = jsonDecode(wardrobe.body);

      resJson.forEach((e) {
        wards.add(WardrobeModel.fromJson(e));
      });

      return wards;
    } catch (e) {
      rethrow;
    }
  }
}
