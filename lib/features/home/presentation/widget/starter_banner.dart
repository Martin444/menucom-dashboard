import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/dinning_model.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';
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
      case RolesUsers.dinning:
      case RolesUsers.food:
        return "Registrá tus platos en menús irresistible";
      case RolesUsers.clothes:
      case RolesUsers.retail:
      case RolesUsers.water_distributor:
      case RolesUsers.grocery:
      case RolesUsers.accessories:
      case RolesUsers.electronics:
      case RolesUsers.pharmacy:
      case RolesUsers.beauty:
      case RolesUsers.construction:
      case RolesUsers.automotive:
      case RolesUsers.pets:
        return 'Registrá tus productos en catálogos flexibles';
      case RolesUsers.service:
        return 'Empezá a gestionar tus servicios';
      default:
        return 'Comenzá a usar el dashboard';
    }
  }

  String getRouteByRole() {
    final role = RolesFuncionts.getTypeRoleByRoleString(widget.user.role!);
    switch (role) {
      case RolesUsers.dinning:
      case RolesUsers.food:
        return PURoutes.REGISTER_MENU_CATEGORY;
      case RolesUsers.clothes:
      case RolesUsers.retail:
      case RolesUsers.water_distributor:
      case RolesUsers.grocery:
      case RolesUsers.accessories:
      case RolesUsers.electronics:
      case RolesUsers.pharmacy:
      case RolesUsers.beauty:
      case RolesUsers.construction:
      case RolesUsers.automotive:
      case RolesUsers.pets:
        return PURoutes.REGISTER_WARDROBES;
      default:
        return PURoutes.HOME;
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
                child: Center(
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
                    Get.toNamed(getRouteByRole());
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
