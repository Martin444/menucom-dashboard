import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/features/login/presentation/controllers/login_controller.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

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
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Menu com',
                        style: PuTextStyle.title1,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      PUInput(
                        labelText: 'Email',
                        hintText: 'Escribe el email',
                        controller: _.emailController,
                        errorText: _.errorTextEmail?.value.isEmpty ?? false
                            ? null
                            : _.errorTextEmail!.value,
                      ),
                      const SizedBox(
                        height: 0,
                      ),
                      PUInput(
                        labelText: 'Contraseña',
                        hintText: 'Contraseña',
                        isPassword: true,
                        errorText: _.errorTextPassword.value.isEmpty
                            ? null
                            : _.errorTextPassword.value,
                        controller: _.passwordController,
                      ),
                      const SizedBox(
                        height: 40,
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
                      Text(
                        'Version: $VERSION_APP',
                        style: PuTextStyle.title1,
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
