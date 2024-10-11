import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/get_funcion_button.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/share_link_menu_dialog.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';

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
                  Text(
                    dinning.dinningLogin.name ?? '',
                    style: PuTextStyle.title1,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.dialog(
                        ShareLinkMenuDialog(
                          idMenu: dinning.dinningLogin.id ?? '',
                        ),
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SvgPicture.asset(
                        PUIcons.iconLink,
                        colorFilter: ColorFilter.mode(
                          PUColors.iconColor,
                          BlendMode.src,
                        ),
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
