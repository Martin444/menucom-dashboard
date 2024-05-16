import '../../model/user_succes_model.dart';

abstract class LoginRepository {
  Future<UserSuccess> loginCommerce({
    required String email,
    required String password,
  });
}
