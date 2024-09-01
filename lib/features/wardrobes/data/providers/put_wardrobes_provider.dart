import 'dart:convert';

import 'package:pickmeup_dashboard/core/exceptions/api_exception.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/repository/put_wardrobes_repository.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

class PutWardrobesProvider extends PutWardrobesRepository {
  @override
  Future<void> putEditWardrobes(PostWardParams params) async {
    try {
      Uri wardrobeCreateURl = Uri.parse('$URL_PICKME_API/wardrobe/edit');
      var wardrobe = await http.put(
        wardrobeCreateURl,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $ACCESS_TOKEN',
        },
        body: jsonEncode(
          {
            "description": params.description,
          },
        ),
      );

      if (wardrobe.statusCode != 201) {
        throw ApiException(
          wardrobe.statusCode,
          wardrobe.body,
        );
      }

      var respJson = jsonDecode(wardrobe.body);
      return respJson;
    } catch (e) {
      rethrow;
    }
  }
}
