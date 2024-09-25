import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/models/dinning_model.dart';
import 'package:pickmeup_dashboard/features/home/models/roles_users.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:svg_flutter/svg.dart';

import '../../../../routes/routes.dart';

class StarterBanner extends StatefulWidget {
  final DinningModel user;
  const StarterBanner({
    super.key,
    required this.user,
  });

  @override
  State<StarterBanner> createState() => _StarterBannerState();
}

class _StarterBannerState extends State<StarterBanner> {
  String getTitleByRole() {
    final role = RolesFuncionts.getTypeRoleByRoleString(widget.user.role!);

    switch (role) {
      case RolesUsers.dining:
        return "Registrá tus platos en menús irresistibles";
      case RolesUsers.clothes:
        return 'Registrá tus prendas\b en guardarropas flexibles';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                PUImages.noDataImageSvg,
                height: 140,
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Flexible(
                  child: Text(
                    getTitleByRole(),
                    textAlign: TextAlign.center,
                    style: PuTextStyle.title5,
                    softWrap: true,
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              SizedBox(
                width: 300,
                child: ButtonPrimary(
                  title: 'Comenzar',
                  onPressed: () {
                    final role = RolesFuncionts.getTypeRoleByRoleString(widget.user.role!);
                    switch (role) {
                      case RolesUsers.dining:
                        Get.toNamed(PURoutes.REGISTER_MENU_CATEGORY);
                        break;
                      case RolesUsers.clothes:
                        Get.toNamed(PURoutes.REGISTER_WARDROBES);
                        break;
                      default:
                    }
                  },
                  load: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
