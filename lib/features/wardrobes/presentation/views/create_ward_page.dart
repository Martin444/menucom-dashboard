import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/getx/wardrobes_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:pu_material/widgets/inputs/pu_input.dart';

class CreateWardPage extends StatefulWidget {
  final bool? isEditPage;

  const CreateWardPage({
    super.key,
    this.isEditPage,
  });

  @override
  State<CreateWardPage> createState() => _CreateWardPageState();
}

class _CreateWardPageState extends State<CreateWardPage> {
  var dinninController = Get.find<DinningController>();
  var wrController = Get.find<WardrobesController>();

  @override
  void dispose() {
    wrController.nameWard.clear();
    super.dispose();
  }

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
                                    Icon(
                                      Icons.arrow_back_ios,
                                      color: PUColors.primaryColor,
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
                                      widget.isEditPage ?? false
                                          ? 'Editá tu guardarropa'
                                          : 'Creá tu nuevo guardarropas',
                                      textAlign: TextAlign.start,
                                      style: PuTextStyle.title1,
                                    ),
                                    Text(
                                      widget.isEditPage ?? false ? 'Renová tus ideas' : 'Dejá que tu imaginación vuele',
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
                              onSubmited: (p0) async {
                                if (widget.isEditPage ?? false) {
                                  _.editWardrobe();
                                  await dinninController.getWardrobebyDining();
                                  Get.offAllNamed(PURoutes.HOME);
                                  return;
                                }
                                await _.postWardrobe();
                                await dinninController.getWardrobebyDining();
                                Get.offAllNamed(PURoutes.HOME);
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ButtonPrimary(
                              title: widget.isEditPage ?? false ? 'Guardar' : 'Crear',
                              onPressed: () async {
                                if (widget.isEditPage ?? false) {
                                  _.editWardrobe();
                                  await dinninController.getWardrobebyDining();
                                  Get.offAllNamed(PURoutes.HOME);
                                  return;
                                }
                                await _.postWardrobe();
                                await dinninController.getWardrobebyDining();
                                Get.offAllNamed(PURoutes.HOME);
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
