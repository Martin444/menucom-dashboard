import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/models/roles_users.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/menu_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/ward_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/get_funcion_button.dart';
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
    var role = RolesFuncionts.getTypeRoleByRoleString(dinninController.dinningLogin.role ?? '');

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
    return GetBuilder<DinningController>(
      builder: (dinning) {
        if (dinning.isLoaginDataUser) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return LayoutBuilder(
          builder: (context, constrains) {
            var isMobile = constrains.maxWidth > 1000;
            return PopScope(
              canPop: false,
              child: Scaffold(
                backgroundColor: PUColors.primaryBackground,
                drawerScrimColor: Colors.transparent,
                drawer: const MenuSIde(),
                body: Row(
                  children: [
                    MenuSIde(
                      isMobile: isMobile,
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Column(
                            children: [
                              // Header
                              HeadDinning(
                                isMobile: isMobile,
                              ),

                              Visibility(
                                visible: isMobile,
                                child: const HeadActions(),
                              ),

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
                          Visibility(
                            visible: !isMobile,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              decoration: BoxDecoration(
                                color: PUColors.primaryBackground,
                              ),
                              child: getActionPrincipalByRole(dinning),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
