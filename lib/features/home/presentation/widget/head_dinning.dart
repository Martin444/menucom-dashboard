import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'mp_oauth_gate_widget.dart';

class HeadDinning extends StatelessWidget {
  final bool? isMobile;
  const HeadDinning({
    super.key,
    this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 768;
        final isLargeScreen = constraints.maxWidth >= 1024;

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

        // Spacer to push content to center and right
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Restaurant name - truncated for mobile
              Flexible(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(controller),
                  child: Text(
                    controller.dinningLogin.name ?? '',
                    style: PuTextStyle.title3.copyWith(
                      fontSize: 16, // Slightly smaller for mobile
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
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
            // Share menu (simplified for mobile)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Get.dialog(
                    MPOAuthGateWidget(
                      idMenu: controller.dinningLogin.id ?? '',
                      redirectUri: 'https://menucom-api-60e608ae2f99.herokuapp.com/payments/oauth/callback',
                    ),
                  );
                },
                child: Icon(
                  FluentIcons.share_24_regular,
                  color: PUColors.iconColor,
                  size: 22,
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
        // Left section - Menu button (hidden on desktop since we have sidebar)
        const Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Empty space or logo could go here
              SizedBox(),
            ],
          ),
        ),

        // Center section - Restaurant name
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => _navigateToProfile(controller),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: PUOverflowTextDetector(
                      message: controller.dinningLogin.name ?? '',
                      children: [
                        Text(
                          controller.dinningLogin.name ?? '',
                          style: PuTextStyle.title3,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right section - Actions
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Share menu
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Get.dialog(
                      MPOAuthGateWidget(
                        idMenu: controller.dinningLogin.id ?? '',
                        redirectUri: 'https://menucom-api-60e608ae2f99.herokuapp.com/payments/oauth/callback',
                      ),
                    );
                  },
                  child: Icon(
                    FluentIcons.share_24_regular,
                    color: PUColors.iconColor,
                    size: 24,
                  ),
                ),
              ),

              if (isLargeScreen) ...[
                const SizedBox(width: 16),
                // Additional actions for large screens could go here
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToProfile(DinningController controller) {
    try {
      var newRoutProfile = PURoutes.USER_PROFILE.replaceFirst(
        ':idUsuario',
        controller.dinningLogin.name!.toLowerCase().split(' ').join('-'),
      );
      Get.toNamed(newRoutProfile);
    } catch (e) {
      print(e);
    }
  }
}
