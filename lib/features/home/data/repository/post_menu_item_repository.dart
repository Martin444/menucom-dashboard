import 'package:pickmeup_dashboard/features/home/models/menu_item_model.dart';

abstract class PostMenuItemRepository {
  Future<MenuItemModel> postMenuItemFromUser(String menuId, MenuItemModel item);
}
