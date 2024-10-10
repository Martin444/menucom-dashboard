import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_item_model.dart';
import 'package:pickmeup_dashboard/features/home/data/provider/post_menu_item_provider.dart';

class PostMenuItemUsesCases {
  PostMenuItemUsesCases();

  Future<MenuItemModel> execute(String menuId, MenuItemModel item) async {
    try {
      var response = await PostMenuItemProvider().postMenuItemFromUser(
        menuId,
        item,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
