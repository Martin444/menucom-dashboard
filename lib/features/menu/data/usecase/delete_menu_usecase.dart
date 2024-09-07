import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';
import 'package:pickmeup_dashboard/features/menu/data/provider/delete_menu_provider.dart';

class DeleteMenuUsecase {
  static Future<dynamic> execute(MenuParams params) {
    try {
      final responseWard = DeleteMenuProvider().deleteMenu(params);
      return responseWard;
    } catch (e) {
      rethrow;
    }
  }
}
