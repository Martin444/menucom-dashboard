import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:menu_dart_api/core/type_comerce_model.dart';
import 'package:pickmeup_dashboard/features/login/controllers/login_controller.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/widgets/card_take_photo.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/inputs/pu_input_dropdown.dart';

import '../../../../routes/routes.dart';

class RegisterCommerce extends StatefulWidget {
  const RegisterCommerce({super.key});

  @override
  State<RegisterCommerce> createState() => _RegisterCommerceState();
}

class _RegisterCommerceState extends State<RegisterCommerce> {
  final _formRegisterKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: GetBuilder<LoginController>(
        builder: (_) {
          return Stack(
            children: [
              Form(
                key: _formRegisterKey,
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
                              height: MediaQuery.of(context).size.height - 100,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                    height: 90,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      FadeIn(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Creá tu cuenta',
                                              textAlign: TextAlign.start,
                                              style: PuTextStyle.title1,
                                            ),
                                            Text(
                                              'Completá los campos con información de tu negocio.',
                                              textAlign: TextAlign.start,
                                              style: PuTextStyle.title2,
                                              softWrap: true,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            CardTakePhoto(
                                              onTaka: () {
                                                _.pickImageDirectory();
                                              },
                                              isTaked: _.fileTaked != null,
                                              photoInBytes: _.fileTaked ?? Uint8List(2),
                                              isLogo: true,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            PUInput(
                                              labelText: 'Email',
                                              hintText: 'Email',
                                              textInputAction: TextInputAction.next,
                                              textInputType: TextInputType.emailAddress,
                                              controller: _.newemailController,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return PUValidators.validatoObligatory(value);
                                                }
                                                if (!PUValidators.validateEmail(value)) {
                                                  return 'Escribe un email valido';
                                                }
                                                return null;
                                              },
                                              errorText: _.errorTextEmail?.value.isEmpty ?? false
                                                  ? null
                                                  : _.errorTextEmail!.value,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            PUInput(
                                              labelText: 'Nombre',
                                              hintText: 'Nombre',
                                              isPassword: false,
                                              textInputAction: TextInputAction.next,
                                              textInputType: TextInputType.name,
                                              errorText:
                                                  _.errorTextPassword.value.isEmpty ? null : _.errorTextPassword.value,
                                              controller: _.newnameController,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            PUInput(
                                              hintText: 'Número de teléfono',
                                              isPassword: false,
                                              textInputAction: TextInputAction.next,
                                              textInputType: TextInputType.phone,
                                              errorText:
                                                  _.errorTextPassword.value.isEmpty ? null : _.errorTextPassword.value,
                                              controller: _.newphoneController,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            PUInputDropDown<TypeComerceModel>(
                                              items: _.listCommerceAvilable.map((e) {
                                                return DropdownMenuItem<TypeComerceModel>(
                                                  key: Key(e.id),
                                                  value: e,
                                                  child: Text(
                                                    e.description,
                                                  ),
                                                );
                                              }).toList(),
                                              errorText: null,
                                              onSelect: (val) {
                                                _.selectTypeComerce(val);
                                              },
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Este campo es obligatrio';
                                                }
                                                return null;
                                              },
                                              label: '',
                                              hintText: 'Tipo de comercio',
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            PUInput(
                                              labelText: 'Contraseña',
                                              hintText: 'Contraseña',
                                              isPassword: true,
                                              textInputAction: TextInputAction.done,
                                              textInputType: TextInputType.visiblePassword,
                                              errorText:
                                                  _.errorTextPassword.value.isEmpty ? null : _.errorTextPassword.value,
                                              controller: _.newpasswordController,
                                              onSubmited: (p0) {
                                                var validRegister = _formRegisterKey.currentState?.validate();
                                                if (validRegister ?? false) {
                                                  _.registerCommerce();
                                                }
                                              },
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            ButtonPrimary(
                                              title: 'Registrate',
                                              onPressed: () {
                                                var validRegister = _formRegisterKey.currentState?.validate();
                                                if (validRegister ?? false) {
                                                  _.registerCommerce();
                                                }
                                              },
                                              load: _.isLogging.value,
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
                                                          text: '¿Ya tenés cuenta? ',
                                                          style: PuTextStyle.description1,
                                                        ),
                                                        TextSpan(
                                                          recognizer: TapGestureRecognizer()
                                                            ..onTap = () {
                                                              Get.toNamed(
                                                                PURoutes.LOGIN,
                                                              );
                                                            },
                                                          text: 'Inicia sesión',
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Version: $VERSION_APP',
                                  style: PuTextStyle.description1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
