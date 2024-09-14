import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config.dart';
import '../../../../core/exceptions/api_exception.dart';
import '../../models/menu_response.dart';
import '../repository/get_menu_repository.dart';

class GetMenuProvider extends GetMenuRespository {
  @override
  Future<MenuResponse> getmenuByDining(String idDining) async {
    Uri userURl = Uri.parse('$URL_PICKME_API/menu/bydining/$idDining');
    try {
      var response = await http.get(
        userURl,
      );
      if (response.statusCode != 200) {
        throw ApiException(
          response.statusCode,
          response.body,
        );
      }
      var respJson = jsonDecode(response.body);

      var menuRespon = MenuResponse.fromJson(respJson);

      return menuRespon;
    } catch (e) {
      rethrow;
    }
  }
}
