import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';

abstract class GetWardrobesRepository {
  Future<List<WardrobeModel>> getWardRobes();
}
