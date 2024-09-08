import 'package:pickmeup_dashboard/features/home/data/provider/post_menu_item_provider.dart';

import '../../models/menu_item_model.dart';

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
