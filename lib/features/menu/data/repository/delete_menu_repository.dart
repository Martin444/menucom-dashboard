import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';

abstract class DeleteMenuRepository {
  Future<void> deleteMenu(MenuParams params);
}
