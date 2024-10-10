import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_item_model.dart';

import '../provider/put_menu_item_provider.dart';

class PutMenuItemUsesCases {
  PutMenuItemUsesCases();

  Future<dynamic> execute(MenuItemModel item) async {
    try {
      var response = await PutMenuItemProvider().putMenuItemFromUser(
        item,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
