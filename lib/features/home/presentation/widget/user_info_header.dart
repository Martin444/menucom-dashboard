import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/mp_oauth_gate_widget.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class UserInfoHeader extends StatelessWidget {
  final DinningController dinning;

  const UserInfoHeader({
    super.key,
    required this.dinning,
  });

  /// Obtiene el rol del usuario actual
  RolesUsers? _getUserRole(String? roleString) {
    if (roleString == null) return null;
    return RolesFuncionts.getTypeRoleByRoleString(roleString);
  }

  /// Verifica si el usuario puede acceder a la vinculación MP OAuth
  /// Los usuarios con rol 'customer' no tienen acceso a esta funcionalidad
  bool _canAccessMPOAuth(RolesUsers? userRole) {
    return userRole != null && userRole != RolesUsers.customer;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(PURoutes.USER_PROFILE);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              dinning.dinningLogin.name ?? 'Usuario',
              style: PuTextStyle.title1,
            ),
          ),
        ),
        // Mostrar icono de vinculación solo si el usuario NO es customer
        if (_canAccessMPOAuth(_getUserRole(dinning.dinningLogin.role)))
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
              child: Tooltip(
                message: 'Vincular con Mercado Pago',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PUColors.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FluentIcons.link_24_regular,
                    color: PUColors.iconColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
