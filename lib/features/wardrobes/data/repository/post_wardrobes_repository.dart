import 'package:pickmeup_dashboard/features/wardrobes/data/params/post_ward_params.dart';

abstract class PostWardrobesRepository {
  Future<void> postNewWardrobes(PostWardParams params);
}
