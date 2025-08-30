import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/get_funcion_button.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/mp_oauth_gate_widget.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class HeadActions extends StatefulWidget {
  const HeadActions({
    super.key,
  });

  @override
  State<HeadActions> createState() => _HeadActionsState();
}

class _HeadActionsState extends State<HeadActions> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (dinning) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: PuStyleContainers.borderBottomContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(PURoutes.USER_PROFILE);
                    },
                    child: Text(
                      dinning.dinningLogin.name ?? '',
                      style: PuTextStyle.title1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.dialog(
                        MPOAuthGateWidget(
                          idMenu: dinning.dinningLogin.id ?? '',
                          redirectUri: 'https://menucom-api-60e608ae2f99.herokuapp.com/payments/oauth/callback',
                        ),
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        FluentIcons.link_24_regular,
                        color: PUColors.iconColor,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 400,
                child: getActionPrincipalByRole(dinning),
              ),
            ],
          ),
        );
      },
    );
  }
}
