import '../../models/menu_model.dart';
import '../provider/get_menu_provider.dart';

class GetMenuUseCase {
  GetMenuUseCase();

  Future<List<MenuModel>> execute(String id) async {
    try {
      var response = await GetMenuProvider().getmenuByDining(id);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
