import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';

import '../../controllers/login_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: GetBuilder<LoginController>(
        builder: (_) {
          return Center(
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'dashLogo',
                              child: Image.asset(
                                PUImages.dashLogo,
                                height: 60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _.pageValidation == 0
                      ? FadeIn(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recuperá tu contraseña',
                                textAlign: TextAlign.start,
                                style: PuTextStyle.title1,
                              ),
                              Text(
                                'Ingresa el email con el que te registraste.',
                                textAlign: TextAlign.start,
                                style: PuTextStyle.title2,
                                softWrap: true,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              PUInput(
                                labelText: 'Email',
                                hintText: 'Email',
                                textInputAction: TextInputAction.next,
                                textInputType: TextInputType.visiblePassword,
                                errorText: _.errorEmailRecovery.isEmpty ? null : _.errorEmailRecovery,
                                controller: _.emailRecoveryController,
                                onSubmited: (p0) {
                                  _.verifyEmailUser();
                                },
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              ButtonPrimary(
                                title: 'Siguiente',
                                onPressed: () {
                                  _.verifyEmailUser();
                                },
                                load: _.isLogging.value,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )
                      : _.pageValidation == 1
                          ? FadeIn(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Revisa tu correo',
                                    textAlign: TextAlign.start,
                                    style: PuTextStyle.title1,
                                  ),
                                  Text(
                                    'Te enviamos un correo a ${_.emailRecoveryController.text} con el código de validación.',
                                    textAlign: TextAlign.start,
                                    style: PuTextStyle.title2,
                                    softWrap: true,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  PUInput(
                                    labelText: 'Código',
                                    hintText: 'Ej: 5555',
                                    textInputAction: TextInputAction.done,
                                    textInputType: TextInputType.visiblePassword,
                                    errorText: _.errorCodeRecovery.isEmpty ? null : _.errorCodeRecovery,
                                    controller: _.codeRecoveryController,
                                    onSubmited: (p0) {
                                      _.validateCodeOtp();
                                    },
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  ButtonPrimary(
                                    title: 'Validar',
                                    onPressed: () {
                                      _.validateCodeOtp();
                                    },
                                    load: _.isLogging.value,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          : _.pageValidation == 2
                              ? FadeIn(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nueva contraseña',
                                        textAlign: TextAlign.start,
                                        style: PuTextStyle.title1,
                                      ),
                                      Text(
                                        'Escribe una contraseña inolvidable.',
                                        textAlign: TextAlign.start,
                                        style: PuTextStyle.title2,
                                        softWrap: true,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      PUInput(
                                        labelText: 'Nueva contraseña',
                                        hintText: 'Nueva contraseña',
                                        isPassword: true,
                                        textInputAction: TextInputAction.done,
                                        errorText: _.errorTextPassword.value.isEmpty ? null : _.errorTextPassword.value,
                                        controller: _.newPassRecoveryController,
                                        onSubmited: (p0) {
                                          _.changePassword();
                                        },
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      ButtonPrimary(
                                        title: 'Cambiar contraseña',
                                        onPressed: () {
                                          _.changePassword();
                                        },
                                        load: _.isLogging.value,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecoveryPassSeccion extends StatelessWidget {
  const RecoveryPassSeccion({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
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
            labelText: 'Nueva contraseña',
            hintText: 'Ingresa una contraseña',
            isPassword: true,
            controller: TextEditingController(),
          ),
          const SizedBox(
            height: 20,
          ),
          PUInput(
            labelText: 'Repite la contraseña',
            hintText: 'Ingresa una contraseña',
            isPassword: true,
            errorText: null,
            controller: TextEditingController(),
            onChanged: (p0) {
              // _.validateRepitePass();
            },
          ),
        ],
      ),
    );
  }
}
