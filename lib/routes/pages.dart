import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/middlewares/auth_middleware.dart';
import 'package:pickmeup_dashboard/core/bindings/menu_navigation_binding.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_binding.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/views/create_item_page.dart';
import 'package:pickmeup_dashboard/features/menu/get/menu_binding.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/views/create_menu_page.dart';
import 'package:pickmeup_dashboard/features/profile/presentation/views/profile_page.dart';
import 'package:pickmeup_dashboard/features/wardrobes/getx/wardrobes_binding.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/views/create_ward_item_page.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/views/create_ward_page.dart';
import 'package:pickmeup_dashboard/features/home/presentation/pages/home_page.dart';
import 'package:pickmeup_dashboard/features/login/controllers/login_bindings.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/change_password_page.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/login_page.dart';
import 'package:pickmeup_dashboard/features/login/presentation/pages/register_commerce.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

import 'package:pickmeup_dashboard/features/home/presentation/pages/mp_oauth_callback_page.dart';

import '../features/orders/presentation/pages/orders_page.dart';

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
        MenuNavigationBinding(),
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
        MenuBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.EDIT_ITEM_MENU,
      transition: Transition.fadeIn,
      page: () => const CreateItemPage(
        isEditPage: true,
      ),
      bindings: [
        DinningBinding(),
        MenuBinding(),
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
    GetPage(
      name: PURoutes.REGISTER_ITEM_WARDROBES,
      transition: Transition.fadeIn,
      page: () => const CreateWardItemPage(
        isEditPage: false,
      ),
      bindings: [
        MenuBinding(),
        WardrobesBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.ORDERS_PAGES,
      transition: Transition.fadeIn,
      page: () => const OrdersPage(),
      bindings: [
        MenuNavigationBinding(),
        MenuBinding(),
        WardrobesBinding(),
        DinningBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.EDIT_ITEM_WARDROBES,
      transition: Transition.fadeIn,
      page: () => const CreateWardItemPage(
        isEditPage: true,
      ),
      bindings: [
        DinningBinding(),
        MenuBinding(),
        WardrobesBinding(),
      ],
    ),
    GetPage(
      name: PURoutes.USER_PROFILE,
      transition: Transition.rightToLeft,
      page: () => const ProfilePage(),
      bindings: [DinningBinding()],
    ),
    GetPage(
      name: PURoutes.MP_OAUTH_CALLBACK,
      page: () => const MPOAuthCallbackPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
