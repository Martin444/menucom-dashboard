import 'package:pickmeup_dashboard/features/home/models/dinning_model.dart';

abstract class DinningRepository {
  Future<DinningModel> getMe();
}
