import '../../models/menu_response.dart';
import '../provider/get_menu_provider.dart';

class GetMenuUseCase {
  GetMenuUseCase();

  Future<MenuResponse> execute(String id) async {
    try {
      var response = await GetMenuProvider().getmenuByDining(id);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
