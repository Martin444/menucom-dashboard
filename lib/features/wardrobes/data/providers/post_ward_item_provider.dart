import 'dart:convert';

import 'package:pickmeup_dashboard/features/wardrobes/data/repository/post_ward_item_repository.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/clothing_item_model.dart';

import '../../../../core/config.dart';
import 'package:http/http.dart' as http;

import '../../../../core/exceptions/api_exception.dart';

class PostWardItemProvider extends PostWardItemRepository {
  @override
  Future<ClothingItemModel> postWardItemFromUser(String menuId, ClothingItemModel item) async {
    try {
      Uri newItemResponseURl = Uri.parse('$URL_PICKME_API/wardrobe/add-item');
      var newItemResponse = await http.post(
        newItemResponseURl,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $ACCESS_TOKEN',
        },
        body: jsonEncode(
          {
            "idWard": menuId,
            "name": item.name,
            "brand": item.brand,
            "photoURL": item.photoURL,
            "sizes": item.sizes,
            "color": item.color,
            "price": item.price,
            "quantity": item.quantity,
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

      return ClothingItemModel.fromJson(respJson);
    } catch (e) {
      rethrow;
    }
  }
}
