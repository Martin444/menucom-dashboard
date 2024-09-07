import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';
import 'package:pickmeup_dashboard/features/menu/data/provider/put_menu_provider.dart';

class PutMenuUsecase {
  static Future<dynamic> execute(MenuParams params) {
    try {
      final responseWard = PutMenuProvider().putEditMenu(params);
      return responseWard;
    } catch (e) {
      rethrow;
    }
  }
}
