import 'package:pickmeup_dashboard/features/login/data/provider/change_password_provider.dart';

class ChangePasswordUseCase {
  ChangePasswordUseCase();

  Future<bool> execute(
    String newPass,
  ) async {
    try {
      var response = await ChangePasswordProvider().changePassword(
        newPass: newPass,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
