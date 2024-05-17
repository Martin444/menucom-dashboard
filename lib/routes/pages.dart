import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/middlewares/auth_middleware.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_binding.dart';
import 'package:pickmeup_dashboard/features/home/presentation/pages/create_item_page.dart';
import 'package:pickmeup_dashboard/features/home/presentation/pages/home_page.dart';
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
      middlewares: [
        AuthMiddleware(),
      ],
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      bindings: [
        DinningBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.REGISTER_ITEM_MENU,
      transition: Transition.fadeIn,
      page: () => const CreateItemPage(),
      bindings: [
        DinningBinding(),
      ],
    ),
  ];
}
