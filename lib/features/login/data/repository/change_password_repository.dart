abstract class ChangePasswordRepository {
  Future<bool> changePassword({
    required String newPass,
  });
}
