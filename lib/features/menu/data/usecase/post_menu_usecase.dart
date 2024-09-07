import 'package:pickmeup_dashboard/features/menu/data/params/menu_params.dart';
import 'package:pickmeup_dashboard/features/menu/data/provider/post_menu_provider.dart';

class PostMenuUsecase {
  static Future<dynamic> execute(MenuParams params) {
    try {
      final responseWard = PostMenuProvider().postNewMenu(params);
      return responseWard;
    } catch (e) {
      rethrow;
    }
  }
}
