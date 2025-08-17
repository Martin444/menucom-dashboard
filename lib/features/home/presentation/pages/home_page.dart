import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/menu_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/ward_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/head_actions.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/starter_banner.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/get_funcion_button.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

import '../widget/head_dinning.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DinningController dinningController;

  @override
  void initState() {
    super.initState();
    dinningController = Get.find<DinningController>();
    dinningController.getMyDinningInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (dinning) {
        if (dinning.isLoaginDataUser) {
          return Scaffold(
            backgroundColor: PUColors.primaryBackground,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 768;
            final isTablet = screenWidth >= 768 && screenWidth < 1024;

            if (isMobile) {
              return _MobileLayout(controller: dinning);
            } else {
              return _DesktopLayout(
                controller: dinning,
                isTablet: isTablet,
              );
            }
          },
        );
      },
    );
  }
}

/// Widget para el layout móvil con drawer
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.controller});

  final DinningController controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: PUColors.primaryBackground,
        drawerScrimColor: Colors.transparent,
        drawer: const MenuSide(isMobile: true),
        body: _MobileContent(controller: controller),
      ),
    );
  }
}

/// Widget para el contenido móvil
class _MobileContent extends StatelessWidget {
  const _MobileContent({required this.controller});

  final DinningController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header móvil
        const HeadDinning(isMobile: true),

        // Contenido principal
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: controller.everyListEmpty
                ? _RoleBasedView(controller: controller, isMobile: true)
                : StarterBanner(user: controller.dinningLogin),
          ),
        ),

        // Actions principales en la parte inferior para mobile
        if (controller.everyListEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: PUColors.bgItem,
              border: Border(
                top: BorderSide(
                  color: PUColors.borderInputColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header de la sección
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '¿Que haremos hoy?',
                      style: PuTextStyle.title3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PUColors.textColor3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Botones principales
                  getActionPrincipalByRole(controller),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget para el layout desktop/tablet
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.controller,
    required this.isTablet,
  });

  final DinningController controller;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: PUColors.primaryBackground,
        body: Row(
          children: [
            // MenuSide fijo
            SizedBox(
              width: isTablet ? 200 : 250,
              child: const MenuSide(isMobile: false),
            ),
            // Contenido principal
            Expanded(
              child: _DesktopContent(
                controller: controller,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para el contenido desktop
class _DesktopContent extends StatelessWidget {
  const _DesktopContent({
    required this.controller,
    required this.isTablet,
  });

  final DinningController controller;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isTablet ? 24.0 : 32.0;
    final verticalPadding = isTablet ? 16.0 : 24.0;

    return Column(
      children: [
        // Header desktop
        const HeadDinning(isMobile: false),

        // Head Actions solo en desktop cuando hay espacio
        if (!isTablet) const HeadActions(),

        // Contenido principal
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: controller.everyListEmpty
                ? _RoleBasedView(controller: controller, isMobile: false)
                : StarterBanner(user: controller.dinningLogin),
          ),
        ),
      ],
    );
  }
}

/// Widget que muestra la vista según el rol del usuario
class _RoleBasedView extends StatelessWidget {
  const _RoleBasedView({
    required this.controller,
    required this.isMobile,
  });

  final DinningController controller;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final role = RolesFuncionts.getTypeRoleByRoleString(
      controller.dinningLogin.role ?? '',
    );

    switch (role) {
      case RolesUsers.clothes:
        return WardsHomeView(isMobile: isMobile);
      case RolesUsers.dinning:
        return MenuHomeView(isMobile: isMobile);
      default:
        return WardsHomeView(isMobile: isMobile);
    }
  }
}
