import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/features/login/controllers/login_controller.dart';
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
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Center(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Menu com',
                                            style: PuTextStyle.title1,
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Column(
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
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          PUInput(
                                            labelText: 'Email',
                                            hintText: 'Email',
                                            controller: _.emailController,
                                            textInputAction: TextInputAction.next,
                                            errorText: _.errorTextEmail?.value.isEmpty ?? false
                                                ? null
                                                : _.errorTextEmail!.value,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          PUInput(
                                            labelText: 'Contraseña',
                                            hintText: 'Contraseña',
                                            isPassword: true,
                                            errorText:
                                                _.errorTextPassword.value.isEmpty ? null : _.errorTextPassword.value,
                                            controller: _.passwordController,
                                            textInputAction: TextInputAction.done,
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
                                    const SizedBox(
                                      height: 60,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                    return isKeyboardVisible
                        ? Container() // No mostrar el widget cuando el teclado esté visible
                        : Container(
                            height: 60,
                            color: PUColors.primaryBackground,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Version: $VERSION_APP',
                                  style: PuTextStyle.description1,
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
