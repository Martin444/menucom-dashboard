import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/providers/put_wardrobes_provider.dart';

class PutWardrobeUsecase {
  static Future<dynamic> execute(PostWardParams params) {
    try {
      final responseWard = PutWardrobesProvider().putEditWardrobes(params);
      return responseWard;
    } catch (e) {
      rethrow;
    }
  }
}
