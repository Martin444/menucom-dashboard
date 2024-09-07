import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/models/roles_users.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/menu_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/ward_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/head_actions.dart';

import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/starter_banner.dart';
import 'package:pu_material/pu_material.dart';

import '../widget/head_dinning.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var dinninController = Get.find<DinningController>();

  @override
  void initState() {
    dinninController.getMyDinningInfo();
    super.initState();
  }

  Widget getViewByRole(bool isMobile) {
    var role = RolesFuncionts.getTypeRoleByRoleString(dinninController.dinningLogin.role!);

    switch (role) {
      case RolesUsers.clothes:
        return WardsHomeView(isMobile: isMobile);
      case RolesUsers.dining:
        return MenuHomeView(isMobile: isMobile);
      default:
        return WardsHomeView(isMobile: isMobile);
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = Get.width < 700;
    return GetBuilder<DinningController>(
      builder: (dinning) {
        if (dinning.isLoaginDataUser) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: PUColors.primaryBackground,
            drawerScrimColor: Colors.transparent,
            body: Row(
              children: [
                const MenuSIde(),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Header
                          const HeadDinning(),

                          const HeadActions(),

                          // Seccion de items del menú
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Row(
                                children: [
                                  // items
                                  dinning.everyListEmpty
                                      ? Flexible(
                                          child: getViewByRole(isMobile),
                                        )
                                      : Expanded(
                                          child: StarterBanner(
                                            user: dinninController.dinningLogin,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
