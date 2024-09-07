import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';

abstract class PutMenuRepository {
  Future<void> putEditMenu(MenuParams params);
}
