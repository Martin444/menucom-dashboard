import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/features/login/presentation/controllers/login_controller.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

import '../../../../routes/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: GetBuilder<LoginController>(
        builder: (_) {
          return Stack(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 80,
                                ),
                                Hero(
                                  tag: 'dashLogo',
                                  child: Image.asset(
                                    PUImages.dashLogo,
                                    height: 90,
                                  ),
                                ),
                                FadeIn(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Menu com',
                                        style: PuTextStyle.title1,
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Inicio de sesión',
                                                textAlign: TextAlign.start,
                                                style: PuTextStyle.title1,
                                              ),
                                              Text(
                                                'Ingresá tus credenciales para continuar.',
                                                textAlign: TextAlign.start,
                                                style: PuTextStyle.title2,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      PUInput(
                                        labelText: 'Email',
                                        hintText: 'Email',
                                        controller: _.emailController,
                                        errorText:
                                            _.errorTextEmail?.value.isEmpty ?? false ? null : _.errorTextEmail!.value,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      PUInput(
                                        labelText: 'Contraseña',
                                        hintText: 'Contraseña',
                                        isPassword: true,
                                        errorText: _.errorTextPassword.value.isEmpty ? null : _.errorTextPassword.value,
                                        controller: _.passwordController,
                                        onSubmited: (value) {
                                          _.loginWithEmailandPassword();
                                        },
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        _.errorTextPassword.value = '';
                                                        Get.toNamed(
                                                          PURoutes.CHANGE_PASSWORD,
                                                        );
                                                      },
                                                    text: '¿Olvidaste tu contraseña?',
                                                    style: PuTextStyle.redirectLink1,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ButtonPrimary(
                                        title: 'Inicia sesión',
                                        onPressed: () {
                                          _.loginWithEmailandPassword();
                                        },
                                        load: _.isLogging.value,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '¿No tenés cuenta? ',
                                                    style: PuTextStyle.description1,
                                                  ),
                                                  TextSpan(
                                                    recognizer: TapGestureRecognizer()
                                                      ..onTap = () {
                                                        _.errorTextEmail?.value = '';
                                                        Get.toNamed(PURoutes.REGISTER_COMMERCE);
                                                      },
                                                    text: 'Registrate',
                                                    style: PuTextStyle.redirectLink1,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text(
                              'Version: $VERSION_APP',
                              style: PuTextStyle.description1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
