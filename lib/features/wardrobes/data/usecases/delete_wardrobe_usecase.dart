import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/providers/delete_wardrobes_provider.dart';

class DeleteWardrobeUsecase {
  static Future<dynamic> execute(PostWardParams params) {
    try {
      final responseWard = DeleteWardrobesProvider().deleteWardrobes(params);
      return responseWard;
    } catch (e) {
      rethrow;
    }
  }
}
