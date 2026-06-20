import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/customer_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/menu_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/ward_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/views/service_home_view.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/head_actions.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/starter_banner.dart';
import 'package:pickmeup_dashboard/features/home/presentation/organisms/mp_link_banner.dart';
import 'package:pickmeup_dashboard/features/home/presentation/organisms/missing_logo_banner.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/get_function_button.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';

import '../widget/head_dinning.dart';
import '../widget/dashboard_error_state.dart';
import '../widget/context_switcher_molecule.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      init: Get.find<DinningController>(),
      builder: (dinning) {
        return Obx(() {
          if (dinning.isLoadingDataUser.value) {
            return Scaffold(
              backgroundColor: PUColors.primaryBackground,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (dinning.hasErrorLoadingUser.value) {
            return DashboardErrorState(
              onRetry: () {
                dinning.getMyDinningInfo();
                dinning.checkMPStatus();
              },
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
        });
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

        // Contenido con scroll que empieza desde el banner de MP
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner de vinculación de Mercado Pago
                      const MPLinkBanner(),

                      // Banner de logo faltante
                      const MissingLogoBanner(),

                      // Contenido principal con altura fija para que los
                      // child views con Expanded funcionen correctamente
                      SizedBox(
                        height: constraints.maxHeight,
                        child: _buildMainContent(controller, isMobile: true),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Footer con acciones principales - solo si tiene comercio o es customer
        if (controller.isCustomerRole || controller.hasSelectedCommerce.value)
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
                if (controller.everyListEmpty.value)
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
                ActionPrincipalByRole(role: controller),
              ],
            ),
          ),
        ),
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
    final horizontalPadding = isTablet ? 24.0 : 24.0;
    final verticalPadding = isTablet ? 16.0 : 24.0;

    return Column(
      children: [
        // Header desktop
        const HeadDinning(isMobile: false),

        // Head Actions solo en desktop cuando hay espacio
        if (!isTablet) const HeadActions(),

        // Contenido principal con scroll que empieza desde el banner de MP
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner de vinculación de Mercado Pago
                      const MPLinkBanner(),

                      // Banner de logo faltante
                      const MissingLogoBanner(),

                      // Contenido principal con altura fija para que los
                      // child views con Expanded funcionen correctamente
                      SizedBox(
                        height: constraints.maxHeight,
                        child: _buildMainContent(controller, isMobile: false),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Decide qué contenido mostrar según el estado del usuario
Widget _buildMainContent(DinningController controller, {required bool isMobile}) {
  if (!controller.isCustomerRole && !controller.hasSelectedCommerce.value) {
    return const _CommerceGate();
  }

  if (!controller.everyListEmpty.value) {
    return _RoleBasedView(controller: controller, isMobile: isMobile);
  }

  return StarterBanner(user: controller.dinningLogin);
}

/// Muestra la pantalla de selección de comercio a pantalla completa
class _CommerceGate extends StatefulWidget {
  const _CommerceGate();

  @override
  State<_CommerceGate> createState() => _CommerceGateState();
}

class _CommerceGateState extends State<_CommerceGate> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_shown && mounted) {
        _shown = true;
        Get.to(
          () => const _CommerceSelectionPage(),
          opaque: true,
          fullscreenDialog: true,
          transition: Transition.noTransition,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Pantalla completa que bloquea interacción hasta seleccionar comercio
class _CommerceSelectionPage extends StatelessWidget {
  const _CommerceSelectionPage();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: PUColors.primaryBackground,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: PUColors.primaryBlueLight.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        FluentIcons.store_microsoft_24_regular,
                        size: 40,
                        color: PUColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Selecciona tu negocio',
                      style: PuTextStyle.title3.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elige con qué comercio quieres operar',
                      style: PuTextStyle.bodySmall.copyWith(
                        color: PUColors.textColorMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    const CommerceSelectionContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
      case RolesUsers.admin:
        // Redirigir a la ruta de admin para evitar doble sidebar y mantener consistencia
        Future.microtask(() => Get.offNamed(PURoutes.ADMIN_DASHBOARD));
        return const Center(child: CircularProgressIndicator());
      case RolesUsers.clothes:
        return WardsHomeView(isMobile: isMobile);
      case RolesUsers.service:
        return ServiceHomeView(isMobile: isMobile);
      case RolesUsers.dinning:
      case RolesUsers.food:
        return MenuHomeView(isMobile: isMobile);
      case RolesUsers.customer:
        return CustomerHomeView(isMobile: isMobile);
      case RolesUsers.event_organizer:
        Future.microtask(() => Get.offNamed(PURoutes.EVENTS));
        return const Center(child: CircularProgressIndicator());
      default:
        return WardsHomeView(isMobile: isMobile);
    }
  }
}
