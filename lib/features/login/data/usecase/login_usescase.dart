import '../../model/user_succes_model.dart';
import '../provider/login_provider.dart';

class LoginUserUseCase {
  LoginUserUseCase();

  Future<UserSuccess> execute(
    String email,
    String password,
  ) async {
    try {
      var response = await LoginProvider().loginCommerce(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
