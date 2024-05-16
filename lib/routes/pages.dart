import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/pages/home_page.dart';
import 'package:pickmeup_dashboard/features/login/presentation/controllers/login_bindings.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/change_password_page.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/login_page.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class PUPages {
  static final List<GetPage> listPages = [
    GetPage(
      name: PURoutes.LOGIN,
      page: () => const LoginPage(),
      bindings: [
        LoginBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.CHANGE_PASSWORD,
      page: () => const ChangePasswordPage(),
      bindings: [
        LoginBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.HOME,
      page: () => const HomePage(),
      bindings: [],
    ),
  ];
}
