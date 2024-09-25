import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

import 'share_link_menu_dialog.dart';

class HeadDinning extends StatelessWidget {
  final bool? isMobile;
  const HeadDinning({
    super.key,
    this.isMobile,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    isMobile ?? true
                        ? const SizedBox()
                        : MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: Icon(
                                Icons.menu,
                                color: PUColors.iconColor,
                                // Icons.copy_all_outlined,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isMobile ?? true
                        ? const SizedBox()
                        : GestureDetector(
                            onTap: () {
                              Get.dialog(
                                ShareLinkMenuDialog(
                                  idMenu: _.dinningLogin.id ?? '',
                                ),
                              );
                            },
                            child: PUOverflowTextDetector(
                              message: _.dinningLogin.name!,
                              children: [
                                Text(
                                  _.dinningLogin.name!,
                                  style: PuTextStyle.title3,
                                ),
                              ],
                            ),
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
                    isMobile ?? true
                        ? MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.notifications,
                                color: PUColors.iconColor,
                                // Icons.copy_all_outlined,
                              ),
                            ),
                          )
                        : Image.network(
                            _.dinningLogin.photoURL!,
                            height: 100,
                            scale: 0.2,
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
