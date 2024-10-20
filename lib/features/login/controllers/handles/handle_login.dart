import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';

class HandleLogin {
  static handleLoginError(dynamic err) {
    GlobalDialogsHandles.snackbarError(
      title: 'Error al Iniciar sesión',
      message: 'No podemos traerte información, vuelve a intentarlo.',
    );
  }
}
