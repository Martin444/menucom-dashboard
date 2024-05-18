import 'dart:convert';

import 'package:pickmeup_dashboard/features/home/models/menu_item_model.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

import '../repository/put_menu_item_repository.dart';

class PutMenuItemProvider extends PutMenuItemRepository {
  @override
  Future putMenuItemFromUser(MenuItemModel item) async {
    try {
      Uri loginURl = Uri.parse('$URL_PICKME_API/menu/edit');
      var login = await http.put(loginURl,
          headers: {
            'Content-type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $ACCESS_TOKEN',
          },
          body: jsonEncode(
            {
              "id": item.id,
              "name": item.name,
              "photoURL": item.photoUrl,
              "price": item.price,
              "deliveryTime": item.deliveryTime
            },
          ));
      var respJson = jsonDecode(login.body);
      // if (respJson['id'] == null) {
      //   throw ApiException(
      //     respJson['statusCode'],
      //     respJson['message'],
      //   );
      // }
      return respJson;
    } catch (e) {
      rethrow;
    }
  }
}
