import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/login/presentation/controllers/login_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return Scaffold(
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(PURoutes.HOME);
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
                            const SizedBox(
                              height: 20,
                            ),
                            CardTakePhoto(
                              onTaka: () {
                                _.pickImageDirectory();
                              },
                              isTaked: _.fileTaked != null,
                              photoInBytes: _.fileTaked,
                              isLogo: true,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            PUInput(
                              labelText: 'Nombre',
                              controller: _.newNameController,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            PUInput(
                              labelText: 'Precio',
                              controller: _.newpriceController,
                              textInputType: TextInputType.number,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            PUInput(
                              labelText: 'Tiempo de preparación (en minutos)',
                              controller: _.newdeliveryController,
                              textInputType: TextInputType.number,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ButtonPrimary(
                              title: 'Crear',
                              onPressed: () {
                                _.createMenuItemInServer();
                              },
                              load: _.isLoadMenuItem,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardTakePhoto extends StatelessWidget {
  final void Function()? onTaka;
  final bool? isTaked;
  final bool? isLogo;
  final Uint8List? photoInBytes;
  const CardTakePhoto({
    super.key,
    this.onTaka,
    this.photoInBytes,
    this.isTaked,
    this.isLogo,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (_) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            onTaka!();
          },
          child: !isTaked!
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: PUColors.bgInput,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_enhance,
                        color: PUColors.textColor1,
                      ),
                      const Text('Cargá tu logo (.jpg, .png)'),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    photoInBytes!,
                    height: 130,
                    width: double.infinity,
                    fit: isLogo! ? BoxFit.contain : BoxFit.cover,
                  ),
                ),
        ),
      );
    });
  }
}
