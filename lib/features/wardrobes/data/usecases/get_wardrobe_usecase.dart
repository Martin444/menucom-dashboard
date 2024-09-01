import 'package:pickmeup_dashboard/features/wardrobes/data/providers/get_wardrobes_provider.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';

class GetWardrobeUsecase {
  static Future<List<WardrobeModel>> execute() async {
    try {
      final response = await GetWardrobesProvider().getWardRobes();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
