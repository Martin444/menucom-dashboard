import 'dart:convert';

import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_item_model.dart';
import 'package:pickmeup_dashboard/features/home/data/repository/post_menu_item_repository.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

import '../../../../core/exceptions/api_exception.dart';

class PostMenuItemProvider extends PostMenuItemRepository {
  @override
  Future<MenuItemModel> postMenuItemFromUser(String menuId, MenuItemModel item) async {
    try {
      Uri newItemResponseURl = Uri.parse('$URL_PICKME_API/menu/add-item');
      var newItemResponse = await http.post(
        newItemResponseURl,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $ACCESS_TOKEN',
        },
        body: jsonEncode(
          {
            "idMenu": menuId,
            "name": item.name,
            "photoURL": item.photoUrl,
            "price": item.price,
            "ingredients": item.ingredients,
            "deliveryTime": item.deliveryTime,
          },
        ),
      );
      if (newItemResponse.statusCode != 201) {
        throw ApiException(
          newItemResponse.statusCode,
          newItemResponse.body,
        );
      }
      var respJson = jsonDecode(newItemResponse.body);

      return MenuItemModel.fromJson(respJson);
    } catch (e) {
      rethrow;
    }
  }
}
