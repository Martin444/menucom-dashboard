import 'dart:convert';

import 'package:pickmeup_dashboard/features/home/data/repository/post_menu_item_repository.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

class PostMenuItemProvider extends PostMenuItemRepository {
  @override
  Future postMenuItemFromUser(String menuId, dynamic item) async {
    try {
      Uri loginURl = Uri.parse('$URL_PICKME_API/menu/create');
      var login = await http.post(loginURl,
          headers: {
            'Content-type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $ACCESS_TOKEN',
          },
          body: jsonEncode(
            {
              "idMenuDirect": menuId,
              "description": 'Menú del día',
              "menuItems": [
                {
                  "name": item!.name,
                  "photoURL": item.photoUrl,
                  "price": item.price,
                  "deliveryTime": item.deliveryTime
                }
              ],
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
