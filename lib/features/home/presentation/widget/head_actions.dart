import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/get_function_button.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/user_info_header.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';

class HeadActions extends StatefulWidget {
  const HeadActions({
    super.key,
  });

  @override
  State<HeadActions> createState() => _HeadActionsState();
}

class _HeadActionsState extends State<HeadActions> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (dinning) {
        // Verificar que los datos estén cargados
        return Obx(() {
          if (dinning.isLoadingDataUser.value) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: PuStyleContainers.borderBottomContainer,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Verificar que dinningLogin no sea null
          if (dinning.dinningLogin.name == null ||
              dinning.dinningLogin.id == null) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: PuStyleContainers.borderBottomContainer,
              child: const Center(
                child: Text(
                  'Error: No se pudo cargar la información del usuario',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: PuStyleContainers.borderBottomContainer,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                if (isMobile) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserInfoHeader(dinning: dinning),
                      const SizedBox(height: 16),
                      ActionPrincipalByRole(role: dinning),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserInfoHeader(dinning: dinning),
                    const SizedBox(width: 20),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: ActionPrincipalByRole(role: dinning),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
      },
    );
  }
}

