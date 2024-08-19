import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';

class HandleRegister {
  static void registerError(String error) {
    GlobalDialogsHandles.snackbarError(
      title: 'Error al registrarte',
      message: error,
    );
  }
}
