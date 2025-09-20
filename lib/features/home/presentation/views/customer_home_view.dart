import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'customer/templates/customer_templates.dart';

/// Vista específica para usuarios con rol customer
///
/// Esta vista proporciona una interfaz adaptada para clientes finales,
/// enfocándose en la experiencia de usuario como consumidor.
/// Implementa atomic design con una estructura modular y reutilizable.
class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  @override
  void initState() {
    super.initState();
    // Cargar comercios al inicializar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommerces();
    });
  }

  void _loadCommerces() {
    final controller = Get.find<DinningController>();
    // Cargar usuarios con roles de dinning y clothes (comercios)
    controller.getUsersByRoles(
      roles: [RolesUsers.dinning, RolesUsers.clothes],
      withVinculedAccount: false,
    );
  }

  void _onCommerceSelected(UserByRoleModel commerce) {
    debugPrint('Selected commerce: ${commerce.name} (${commerce.email})');
    // TODO: Implementar navegación al detalle del comercio
    // Get.toNamed('/commerce-detail', arguments: commerce);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (controller) {
        // Obtener nombre del usuario, con fallback
        final userName = controller.dinningLogin.name ?? 'Cliente';

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: widget.isMobile
                    ? CustomerMobileTemplate(
                        userName: userName,
                        commercesList: controller.usersByRolesList,
                        isLoadingCommerces: controller.isLoadingUsersByRoles,
                        onCommerceSelected: _onCommerceSelected,
                        accessTokenHashed: controller.getHashedAccessToken(),
                      )
                    : CustomerDesktopTemplate(
                        userName: userName,
                        commercesList: controller.usersByRolesList,
                        isLoadingCommerces: controller.isLoadingUsersByRoles,
                        onCommerceSelected: _onCommerceSelected,
                        accessTokenHashed: controller.getHashedAccessToken(),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
