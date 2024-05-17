import 'package:pickmeup_dashboard/features/home/data/provider/dinning_provider.dart';
import 'package:pickmeup_dashboard/features/home/models/dinning_model.dart';

class GetDinningUseCase {
  GetDinningUseCase();

  Future<DinningModel> execute() async {
    try {
      var response = await DinningProvider().getMe();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
