import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';
import 'package:pickmeup_dashboard/features/wardrobes/data/providers/post_wardrobes_provider.dart';

class PostWardrobeUsecase {
  static Future<dynamic> execute(PostWardParams params) {
    try {
      final responseWard = PostWardrobesProvider().postNewWardrobes(params);
      return responseWard;
    } catch (e) {
      rethrow;
    }
  }
}
