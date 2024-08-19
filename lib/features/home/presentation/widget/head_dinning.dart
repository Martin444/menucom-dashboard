import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pu_material/pu_material.dart';

class HeadDinning extends StatelessWidget {
  const HeadDinning({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Color(0xFFBCBCBC),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Get.dialog(
                          //   ShareLinkMenuDialog(
                          //     idMenu: _.dinningLogin.id ?? '',
                          //   ),
                          // );
                        },
                        child: Icon(
                          Icons.notifications,
                          color: PUColors.iconColor,
                          // Icons.copy_all_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
