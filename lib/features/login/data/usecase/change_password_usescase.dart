import 'package:pickmeup_dashboard/features/login/data/provider/change_password_provider.dart';
import 'package:pickmeup_dashboard/features/login/model/change_password_params.dart';

class ChangePasswordUseCase {
  ChangePasswordUseCase();

  Future<dynamic> execute(
    ChangePasswordParams newPass,
  ) async {
    try {
      var response = await ChangePasswordProvider().changePassword(
        params: newPass,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
