import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/models/roles_users.dart';
import 'package:pu_material/pu_material.dart';

import '../../../../routes/routes.dart';
import '../controllers/dinning_controller.dart';

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
