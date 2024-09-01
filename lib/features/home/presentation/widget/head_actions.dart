import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:svg_flutter/svg.dart';

class HeadActions extends StatelessWidget {
  const HeadActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(builder: (dinning) {
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
                SvgPicture.asset(
                  PUIcons.iconLink,
                  colorFilter: ColorFilter.mode(
                    PUColors.iconColor,
                    BlendMode.src,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 200,
              child: getActionPrincipalByRole(dinning.dinningLogin.role!),
            ),
          ],
        ),
      );
    });
  }
}

Widget getActionPrincipalByRole(String role) {
  switch (role) {
    case 'dining':
      return ButtonPrimary(
        title: 'Nuevo Menú',
        onPressed: () {
          Get.toNamed(
            PURoutes.REGISTER_ITEM_MENU,
          );
        },
        load: false,
      );
    case 'clothes':
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
        onPressed: () {
          Get.toNamed(
            PURoutes.REGISTER_ITEM_MENU,
          );
        },
        load: false,
      );
  }
}
