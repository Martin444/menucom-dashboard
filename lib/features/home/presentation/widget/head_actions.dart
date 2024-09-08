import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/share_link_menu_dialog.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:pu_material/widgets/buttons/button_secundary.dart';
import 'package:svg_flutter/svg.dart';

import '../../models/roles_users.dart';

class HeadActions extends StatefulWidget {
  const HeadActions({
    super.key,
  });

  @override
  State<HeadActions> createState() => _HeadActionsState();
}

class _HeadActionsState extends State<HeadActions> {
  Widget getActionPrincipalByRole(DinningController role) {
    final roleByRoleUser = RolesFuncionts.getTypeRoleByRoleString(role.dinningLogin.role!);

    switch (roleByRoleUser) {
      case RolesUsers.dining:
        if (role.menusList.isEmpty) {
          return ButtonPrimary(
            title: 'Nuevo Menú',
            onPressed: () {
              Get.toNamed(
                PURoutes.REGISTER_MENU_CATEGORY,
              );
            },
            load: false,
          );
        }
        return Row(
          children: [
            Flexible(
              child: ButtonSecundary(
                title: 'Nuevo plato',
                onPressed: () {
                  Get.toNamed(
                    PURoutes.REGISTER_ITEM_MENU,
                  );
                },
                load: false,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: ButtonPrimary(
                title: 'Nuevo Menú',
                onPressed: () {
                  Get.toNamed(
                    PURoutes.REGISTER_MENU_CATEGORY,
                  );
                },
                load: false,
              ),
            ),
          ],
        );
      case RolesUsers.clothes:
        return ButtonPrimary(
          title: 'Nuevo guardarropas',
          onPressed: () {
            Get.toNamed(PURoutes.REGISTER_WARDROBES);
          },
          load: false,
        );
      default:
        return ButtonPrimary(
          title: 'Nuevo',
          onPressed: () {},
          load: false,
        );
    }
  }

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
