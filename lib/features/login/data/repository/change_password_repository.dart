import 'package:pickmeup_dashboard/features/login/model/change_password_params.dart';

abstract class ChangePasswordRepository {
  Future<dynamic> changePassword({
    required ChangePasswordParams params,
  });
}
