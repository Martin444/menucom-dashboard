import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/get_function_button.dart';

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
        return Obx(() {
          if (dinning.isLoadingDataUser.value) {
            return const SizedBox.shrink();
          }

          if (dinning.dinningLogin.name == null ||
              dinning.dinningLogin.id == null) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: PuStyleContainers.borderBottomContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: ActionPrincipalByRole(role: dinning),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

