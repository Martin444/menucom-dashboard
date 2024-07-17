import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/share_link_menu_dialog.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class HeadDinning extends StatelessWidget {
  const HeadDinning({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: const Icon(Icons.menu_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_.dinningLogin.name}',
                      style: PuTextStyle.title3,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Get.dialog(
                            ShareLinkMenuDialog(
                              idMenu: _.dinningLogin.id ?? '',
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.share_rounded,
                          // Icons.copy_all_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(_.dinningLogin.photoURL!),
                    )
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
