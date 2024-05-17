import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class HeadDinning extends StatelessWidget {
  const HeadDinning({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(builder: (_) {
      return Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: PUColors.bgHeader,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  '${_.dinningLogin.name}',
                  style: PuTextStyle.title3,
                ),
                SizedBox(
                  width: 10,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(_.dinningLogin.photoURL!),
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}
