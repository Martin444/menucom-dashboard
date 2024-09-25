import 'package:pickmeup_dashboard/features/wardrobes/model/clothing_item_model.dart';

abstract class PostWardItemRepository {
  Future<ClothingItemModel> postWardItemFromUser(String menuId, ClothingItemModel item);
}
