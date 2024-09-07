import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/middlewares/auth_middleware.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_binding.dart';
import 'package:pickmeup_dashboard/features/home/presentation/pages/create_item_page.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/get/menu_binding.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/views/create_menu_page.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/getx/wardrobes_binding.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/views/create_ward_page.dart';
import 'package:pickmeup_dashboard/features/home/presentation/pages/home_page.dart';
import 'package:pickmeup_dashboard/features/login/presentation/controllers/login_bindings.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/change_password_page.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/login_page.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/register_commerce.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class PUPages {
  static final List<GetPage> listPages = [
    GetPage(
      name: PURoutes.LOGIN,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
      bindings: [
        LoginBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.REGISTER_COMMERCE,
      page: () => const RegisterCommerce(),
      transition: Transition.fadeIn,
      bindings: [
        LoginBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.CHANGE_PASSWORD,
      page: () => const ChangePasswordPage(),
      transition: Transition.fadeIn,
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
        WardrobesBinding(),
        MenuBinding(),
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
    GetPage(
      name: PURoutes.REGISTER_WARDROBES,
      transition: Transition.fadeIn,
      page: () => const CreateWardPage(),
      bindings: [
        WardrobesBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.EDIT_WARDROBES,
      transition: Transition.fadeIn,
      page: () => const CreateWardPage(
        isEditPage: true,
      ),
      bindings: [
        WardrobesBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.REGISTER_MENU_CATEGORY,
      transition: Transition.fadeIn,
      page: () => const CreateMenuPage(),
      bindings: [
        MenuBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.EDIT_MENU_CATEGORY,
      transition: Transition.fadeIn,
      page: () => const CreateMenuPage(
        isEditPage: true,
      ),
      bindings: [
        MenuBinding(),
      ],
    ),
  ];
}
