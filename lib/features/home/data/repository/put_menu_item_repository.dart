import 'package:pickmeup_dashboard/features/home/models/menu_item_model.dart';

abstract class PutMenuItemRepository {
  Future<dynamic> putMenuItemFromUser(MenuItemModel item);
}
