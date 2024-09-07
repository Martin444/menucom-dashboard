import 'dart:convert';

import 'package:pickmeup_dashboard/core/exceptions/api_exception.dart';
import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';
import 'package:pickmeup_dashboard/features/menu/data/repository/put_menu_repository.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

class PutMenuProvider extends PutMenuRepository {
  @override
  Future<void> putEditMenu(MenuParams params) async {
    try {
      Uri wardrobeCreateURl = Uri.parse('$URL_PICKME_API/menu/edit');
      var wardrobe = await http.put(
        wardrobeCreateURl,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $ACCESS_TOKEN',
        },
        body: jsonEncode(
          {
            "id": params.id,
            "description": params.description,
          },
        ),
      );

      if (wardrobe.statusCode != 200) {
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
