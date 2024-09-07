import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';

abstract class PostMenuRepository {
  Future<void> postNewMenu(MenuParams params);
}
