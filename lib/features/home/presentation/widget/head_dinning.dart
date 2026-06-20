import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/overflow_text.dart';

import 'mp_oauth_gate_widget.dart';
import 'context_switcher_molecule.dart';

class HeadDinning extends StatelessWidget {
  final bool? isMobile;
  const HeadDinning({
    super.key,
    this.isMobile,
  });

  /// Obtiene el rol del usuario actual
  RolesUsers? _getUserRole(String? roleString) {
    if (roleString == null) return null;
    return RolesFuncionts.getTypeRoleByRoleString(roleString);
  }

  /// Verifica si el usuario puede acceder a la vinculación MP OAuth
  /// Los usuarios con rol 'customer' no tienen acceso a esta funcionalidad
  bool _canAccessMPOAuth(RolesUsers? userRole) {
    return userRole != null && userRole != RolesUsers.customer;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < kMobileBreakpoint;
        final isLargeScreen = constraints.maxWidth >= kTabletBreakpoint;

        // Determine if we should use mobile layout
        final useMobileLayout = isMobile ?? isSmallScreen;

        return GetBuilder<DinningController>(
          builder: (_) {
            return Container(
              height: 60,
              padding: EdgeInsets.symmetric(
                horizontal: useMobileLayout ? 12 : 20,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Color(0xFFBCBCBC),
                  ),
                ),
              ),
              child: useMobileLayout ? _buildMobileLayout(_, context) : _buildDesktopLayout(_, context, isLargeScreen),
            );
          },
        );
      },
    );
  }

  Widget _buildMobileLayout(DinningController controller, BuildContext context) {
    return Row(
      children: [
        // Menu icon for mobile drawer
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Icon(
              FluentIcons.line_horizontal_3_24_regular,
              color: PUColors.iconColor,
              size: 24,
            ),
          ),
        ),

        // Center section - Business name + context switcher
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(controller),
                  child: Text(
                    controller.isCustomerRole
                        ? (controller.dinningLogin.name ?? '')
                        : (controller.dinningLogin.businessName ?? ''),
                    style: PuTextStyle.title3.copyWith(
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const ContextSwitcherMolecule(compact: true),
            ],
          ),
        ),

        // Right actions for mobile
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Notifications
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // Add notification handling
                },
                child: Icon(
                  FluentIcons.alert_24_regular,
                  color: PUColors.iconColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Share menu (Vinculación MP) - Solo para usuarios NO customer
            if (_canAccessMPOAuth(_getUserRole(controller.dinningLogin.role)))
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Get.dialog(
                      MPOAuthGateWidget(
                        idMenu: controller.dinningLogin.id ?? '',
                        redirectUri: Config.mpRedirectUri,
                      ),
                    );
                  },
                  child: Tooltip(
                    message: 'Vincular con Mercado Pago',
                    child: Icon(
                      FluentIcons.share_24_regular,
                      color: PUColors.iconColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(DinningController controller, BuildContext context, bool isLargeScreen) {
    return Row(
      children: [
        // Left spacer - balanced with right actions
        const Spacer(flex: 3),

        // Center section - Business name + context switcher
        Expanded(
          flex: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(controller),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: PUOverflowTextDetector(
                      message: controller.isCustomerRole
                          ? (controller.dinningLogin.name ?? '')
                          : (controller.dinningLogin.businessName ?? ''),
                      children: [
                        Text(
                          controller.isCustomerRole
                              ? (controller.dinningLogin.name ?? '')
                              : (controller.dinningLogin.businessName ?? ''),
                          style: PuTextStyle.title3,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const ContextSwitcherMolecule(),
            ],
          ),
        ),

        // Right section - Actions
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    FluentIcons.alert_24_regular,
                    color: PUColors.iconColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              if (_canAccessMPOAuth(_getUserRole(controller.dinningLogin.role)))
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Get.dialog(
                        MPOAuthGateWidget(
                          idMenu: controller.dinningLogin.id ?? '',
                          redirectUri: Config.mpRedirectUri,
                        ),
                      );
                    },
                    child: Tooltip(
                      message: 'Vincular con Mercado Pago',
                      child: Icon(
                        FluentIcons.share_24_regular,
                        color: PUColors.iconColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),

              if (isLargeScreen) ...[
                const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToProfile(DinningController controller) {
    try {
      if (controller.isCustomerRole) {
        final userName = controller.dinningLogin.name ?? 'usuario';
        var newRoutProfile = PURoutes.USER_PROFILE.replaceFirst(
          ':idUsuario',
          userName.toLowerCase().split(' ').join('-'),
        );
        Get.toNamed(newRoutProfile);
      } else {
        Get.toNamed(PURoutes.BUSINESS_PROFILE);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
