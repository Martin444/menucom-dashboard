import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
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
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  _.pickImageDirectory();
                                },
                                child: _.fileTaked == null
                                    ? Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 60,
                                        ),
                                        decoration: BoxDecoration(
                                          color: PUColors.bgHeader,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.camera_enhance,
                                              color: PUColors.textColor1,
                                            ),
                                            Text('Carga una imagen'),
                                          ],
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          _.fileTaked!,
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
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
                              load: false,
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
