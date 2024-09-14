import '../../models/menu_response.dart';

abstract class GetMenuRespository {
  Future<MenuResponse> getmenuByDining(String idDining);
}
