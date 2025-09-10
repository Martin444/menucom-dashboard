import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';
import 'package:pu_material/pu_material.dart';

import '../../../../routes/routes.dart';
import '../../controllers/dinning_controller.dart';

Widget getActionPrincipalByRole(DinningController role) {
  // Verificar que los datos estén cargados
  if (role.isLoaginDataUser) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Verificar que dinningLogin y role no sean null
  if (role.dinningLogin.role == null || role.dinningLogin.role!.isEmpty) {
    return const Center(
      child: Text(
        'Error: No se pudo cargar la información del usuario',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  final roleByRoleUser = RolesFuncionts.getTypeRoleByRoleString(role.dinningLogin.role!);

  switch (roleByRoleUser) {
    case RolesUsers.dinning:
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
      if (role.wardList.isEmpty) {
        return ButtonPrimary(
          title: 'Nuevo guardarropas',
          onPressed: () {
            Get.toNamed(PURoutes.REGISTER_WARDROBES);
          },
          load: false,
        );
      }
      return Row(
        children: [
          Flexible(
            child: ButtonSecundary(
              title: 'Nueva prenda',
              onPressed: () {
                Get.toNamed(
                  PURoutes.REGISTER_ITEM_WARDROBES,
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
              title: 'Nuevo guardarropas',
              onPressed: () {
                Get.toNamed(PURoutes.REGISTER_WARDROBES);
              },
              load: false,
            ),
          ),
        ],
      );

    default:
      return ButtonPrimary(
        title: 'Error en el rol $roleByRoleUser',
        onPressed: () {},
        load: false,
      );
  }
}
