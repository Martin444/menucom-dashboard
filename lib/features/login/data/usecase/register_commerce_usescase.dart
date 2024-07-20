import 'package:pickmeup_dashboard/features/login/data/provider/register_commerce_provider.dart';

import '../../model/user_succes_model.dart';

class RegisterCommerceUsescase {
  RegisterCommerceUsescase();

  Future<UserSuccess> execute({
    required String photo,
    required String email,
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      var response = await RegisterCommerceProvider().registerCommerce(
        photo: photo,
        email: email,
        name: name,
        password: password,
        phone: phone,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
