import 'package:pickmeup_dashboard/features/wardrobes/data/params/wardrobe_response_params.dart';

abstract class GetClothingsRespository {
  Future<WardrobeResponseParams> getClothingByUserAcount(String idUser);
}
