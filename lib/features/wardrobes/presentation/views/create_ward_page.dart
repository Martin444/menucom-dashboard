import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/getx/wardrobes_controller.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:pu_material/widgets/inputs/pu_input.dart';

class CreateWardPage extends StatefulWidget {
  const CreateWardPage({super.key});

  @override
  State<CreateWardPage> createState() => _CreateWardPageState();
}

class _CreateWardPageState extends State<CreateWardPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<WardrobesController>(
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
                                  Get.back();
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
                              height: 100,
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Creá tu nuevo guardarropas',
                                      textAlign: TextAlign.start,
                                      style: PuTextStyle.title1,
                                    ),
                                    Text(
                                      'Que tu imaginación vuele',
                                      textAlign: TextAlign.start,
                                      style: PuTextStyle.title2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            PUInput(
                              hintText: 'Nombre',
                              controller: _.nameWard,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ButtonPrimary(
                              title: 'Crear',
                              onPressed: () {
                                _.postWardrobe();
                              },
                              load: _.isLoadWard,
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
