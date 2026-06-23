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
    if (role.isLoadingDataUser.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (role.dinningLogin.role == null || role.dinningLogin.role!.isEmpty) {
      return DashboardErrorState(
        isCompact: true,
        onRetry: () => role.getMyDinningInfo(),
      );
    }

    final isFreePlan = Get.isRegistered<MembershipController>()
        ? (Get.find<MembershipController>().currentPlan.value?.toUpperCase() ==
                'FREE' ||
            Get.find<MembershipController>().currentPlan.value == null)
        : true;

    final roleByRoleUser =
        RolesFuncionts.getTypeRoleByRoleString(role.dinningLogin.role ?? '');

    final config = _getRoleConfig(roleByRoleUser);
    if (config == null) {
      return ButtonPrimary(title: 'Error en el rol', onPressed: () {}, load: false);
    }

    if (config.onTap != null) {
      return ButtonPrimary(title: config.onTapLabel!, onPressed: config.onTap, load: false);
    }

    final listIsEmpty = roleByRoleUser == RolesUsers.dinning || roleByRoleUser == RolesUsers.food
        ? role.menusList.isEmpty
        : role.wardList.isEmpty;

    if (listIsEmpty) {
      return ButtonPrimary(
        title: config.emptyListLabel,
        onPressed: () => Get.toNamed(config.emptyListRoute),
        load: false,
      );
    }

    if (isFreePlan) {
      return ButtonSecundary(
        title: config.singleItemLabel,
        onPressed: () => Get.toNamed(config.singleItemRoute),
        load: false,
      );
    }

    return Row(
      children: [
        Flexible(
          child: ButtonSecundary(
            title: config.secondaryLabel,
            onPressed: () => Get.toNamed(config.secondaryRoute),
            load: false,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: ButtonPrimary(
            title: config.primaryLabel,
            onPressed: () => Get.toNamed(config.primaryRoute),
            load: false,
          ),
        ),
      ],
    );
  }

  RoleActionConfig? _getRoleConfig(RolesUsers? roleType) {
    switch (roleType) {
      case RolesUsers.dinning:
      case RolesUsers.food:
        return RoleActionConfig(
          emptyListLabel: 'Nuevo Menú',
          emptyListRoute: PURoutes.REGISTER_MENU_CATEGORY,
          singleItemLabel: 'Nuevo plato',
          singleItemRoute: PURoutes.REGISTER_ITEM_MENU,
          secondaryLabel: 'Nuevo plato',
          secondaryRoute: PURoutes.REGISTER_ITEM_MENU,
          primaryLabel: 'Nuevo Menú',
          primaryRoute: PURoutes.REGISTER_MENU_CATEGORY,
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
        return RoleActionConfig(
          emptyListLabel: 'Nuevo catálogo',
          emptyListRoute: PURoutes.REGISTER_WARDROBES,
          singleItemLabel: 'Nuevo producto',
          singleItemRoute: PURoutes.REGISTER_ITEM_WARDROBES,
          secondaryLabel: 'Nuevo producto',
          secondaryRoute: PURoutes.REGISTER_ITEM_WARDROBES,
          primaryLabel: 'Nuevo catálogo',
          primaryRoute: PURoutes.REGISTER_WARDROBES,
        );
      case RolesUsers.customer:
        return RoleActionConfig(
          emptyListLabel: 'Comenzá a emprender',
          emptyListRoute: PURoutes.BUSINESS_TYPE_SELECTION,
          singleItemLabel: 'Nueva prenda',
          singleItemRoute: PURoutes.REGISTER_ITEM_WARDROBES,
          secondaryLabel: 'Nueva prenda',
          secondaryRoute: PURoutes.REGISTER_ITEM_WARDROBES,
          primaryLabel: 'Nuevo guardarropas',
          primaryRoute: PURoutes.REGISTER_WARDROBES,
        );
      case RolesUsers.service:
        return RoleActionConfig(
          emptyListLabel: '',
          emptyListRoute: '',
          singleItemLabel: '',
          singleItemRoute: '',
          secondaryLabel: '',
          secondaryRoute: '',
          primaryLabel: '',
          primaryRoute: '',
          onTap: () {
            Get.snackbar('Próximamente', 'La gestión de servicios estará disponible pronto',
                snackPosition: SnackPosition.TOP);
          },
          onTapLabel: 'Gestionar servicios',
        );
      case RolesUsers.event_organizer:
        return RoleActionConfig(
          emptyListLabel: '',
          emptyListRoute: '',
          singleItemLabel: '',
          singleItemRoute: '',
          secondaryLabel: '',
          secondaryRoute: '',
          primaryLabel: '',
          primaryRoute: '',
          onTap: () => Get.toNamed(PURoutes.EVENT_CREATE),
          onTapLabel: 'Nuevo evento',
        );
      default:
        return null;
    }
  }
}
