import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';

import '../controllers/login_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryColor,
      body: GetBuilder<LoginController>(
        builder: (_) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(PUImages.dashLogo),
                      const SizedBox(
                        height: 20,
                      ),
                      PUInput(
                        labelText: 'Nueva contraseña',
                        hintText: 'Ingresa una contraseña',
                        isPassword: true,
                        controller: _.newPassController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      PUInput(
                        labelText: 'Repite la contraseña',
                        hintText: 'Ingresa una contraseña',
                        isPassword: true,
                        errorText: _.errorRepitPass?.value.isEmpty ?? false
                            ? null
                            : _.errorRepitPass!.value,
                        controller: _.newPassRepitController,
                        onChanged: (p0) {
                          _.validateRepitePass();
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ButtonPrimary(
                        title: 'Cambiar contraseña',
                        onPressed: () {
                          if (_.errorRepitPass!.value.isEmpty) {
                            _.changePasswordCommerce();
                          }
                        },
                        load: _.isLogging.value,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
