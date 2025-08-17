import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/pu_material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return Scaffold(
          body: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          Get.back();
                        } else {
                          Get.offAllNamed(PURoutes.HOME);
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                          ),
                          Text(
                            'Volver',
                            style: PuTextStyle.description1,
                          )
                        ],
                      ),
                    ),
                  ),
                  PuRobustNetworkImage(
                    imageUrl: _.dinningLogin.photoURL!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    _.dinningLogin.name!,
                    style: PuTextStyle.title1,
                  ),
                  Text(
                    _.dinningLogin.email!,
                    style: PuTextStyle.title2,
                  ),
                  Text(
                    _.dinningLogin.phone!,
                    style: PuTextStyle.title2,
                  ),
                  const ListTile(
                    title: Text('Métodos de pago'),
                    subtitle: Text('Elige con que querés cobrar'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
