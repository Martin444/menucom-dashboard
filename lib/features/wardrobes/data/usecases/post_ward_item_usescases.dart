import 'package:pickmeup_dashboard/features/wardrobes/data/providers/post_ward_item_provider.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/clothing_item_model.dart';

class PostWardItemUsesCases {
  PostWardItemUsesCases();

  Future<ClothingItemModel> execute(String menuId, ClothingItemModel item) async {
    try {
      var response = await PostWardItemProvider().postWardItemFromUser(
        menuId,
        item,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
