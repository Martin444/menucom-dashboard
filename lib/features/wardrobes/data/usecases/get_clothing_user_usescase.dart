import 'package:pickmeup_dashboard/features/wardrobes/data/params/wardrobe_response_params.dart';

import '../providers/get_wardrobe_provider.dart';

class GetClothingUserUsescase {
  GetClothingUserUsescase();

  Future<WardrobeResponseParams> execute(String id) async {
    try {
      var response = await GetClothingProvider().getClothingByUserAcount(id);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
