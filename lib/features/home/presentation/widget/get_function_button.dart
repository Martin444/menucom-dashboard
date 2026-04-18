import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';
import 'package:pu_material/pu_material.dart';

import '../../../../routes/routes.dart';
import '../../controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';

class ActionPrincipalByRole extends StatelessWidget {
  final DinningController role;

  const ActionPrincipalByRole({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // Verificar que los datos estén cargados
    if (role.isLoadingDataUser.value) {
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

    // Verificar si es plan gratuito
    final isFreePlan = Get.isRegistered<MembershipController>()
        ? (Get.find<MembershipController>().currentPlan.value?.toUpperCase() ==
                'FREE' ||
            Get.find<MembershipController>().currentPlan.value == null)
        : true;

    final roleByRoleUser =
        RolesFuncionts.getTypeRoleByRoleString(role.dinningLogin.role ?? '');

    switch (roleByRoleUser) {
      case RolesUsers.dinning:
      case RolesUsers.food:
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

        // Si es plan gratuito y ya tiene un catálogo, solo permitir agregar items
        if (isFreePlan) {
          return ButtonSecundary(
            title: 'Nuevo plato',
            onPressed: () {
              Get.toNamed(
                PURoutes.REGISTER_ITEM_MENU,
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
        if (role.wardList.isEmpty) {
          return ButtonPrimary(
            title: 'Nuevo catálogo',
            onPressed: () {
              Get.toNamed(PURoutes.REGISTER_WARDROBES);
            },
            load: false,
          );
        }

        // Si es plan gratuito y ya tiene un catálogo, solo permitir agregar productos
        if (isFreePlan) {
          return ButtonSecundary(
            title: 'Nuevo producto',
            onPressed: () {
              Get.toNamed(
                PURoutes.REGISTER_ITEM_WARDROBES,
              );
            },
            load: false,
          );
        }

        return Row(
          children: [
            Flexible(
              child: ButtonSecundary(
                title: 'Nuevo producto',
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
                title: 'Nuevo catálogo',
                onPressed: () {
                  Get.toNamed(PURoutes.REGISTER_WARDROBES);
                },
                load: false,
              ),
            ),
          ],
        );
      case RolesUsers.customer:
        if (role.wardList.isEmpty) {
          return ButtonPrimary(
            title: 'Comenzá a emprender',
            onPressed: () {
              Get.toNamed(PURoutes.BUSINESS_TYPE_SELECTION);
            },
            load: false,
          );
        }

        // Si es plan gratuito y ya tiene un catálogo, solo permitir agregar prendas
        if (isFreePlan) {
          return ButtonSecundary(
            title: 'Nueva prenda',
            onPressed: () {
              Get.toNamed(
                PURoutes.REGISTER_ITEM_WARDROBES,
              );
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

      case RolesUsers.service:
        return ButtonPrimary(
          title: 'Gestionar servicios',
          onPressed: () {
            Get.snackbar(
              'Próximamente',
              'La gestión de servicios estará disponible pronto',
              snackPosition: SnackPosition.TOP,
            );
          },
          load: false,
        );

      default:
        return ButtonPrimary(
          title: 'Error en el rol',
          onPressed: () {},
          load: false,
        );
    }
  }
}
