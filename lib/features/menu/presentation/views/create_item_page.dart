import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/login/controllers/login_controller.dart';
import 'package:pickmeup_dashboard/features/menu/get/menu_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/inputs/pu_input_tags.dart';

class CreateItemPage extends StatefulWidget {
  final bool? isEditPage;

  const CreateItemPage({
    super.key,
    this.isEditPage,
  });
  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  var keyFormCreateItem = GlobalKey<FormState>();
  var dinning = Get.find<DinningController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenusController>(
      builder: (_) {
        _.menuSelected = dinning.menuSelected;
        return Scaffold(
          body: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (Navigator.of(context).canPop()) {
                                  Get.back();
                                } else {
                                  Get.offAllNamed(PURoutes.HOME);
                                }
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
                          Form(
                            key: keyFormCreateItem,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.width > 1000 ? 80 : 30,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.isEditPage ?? false ? 'Editá tu menú' : 'Creá tu nuevo plato',
                                          textAlign: TextAlign.start,
                                          style: PuTextStyle.title1,
                                        ),
                                        Text(
                                          widget.isEditPage ?? false ? 'Renová tus ideas' : 'Deleitá a tus clientes',
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
                                CardTakePhoto(
                                  title: 'Cargá la foto de tu platillo (jpg, png)',
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
                                  hintText: 'Nombre',
                                  controller: _.newNameController,
                                  validator: (name) {
                                    if (name?.isEmpty ?? false) {
                                      return 'Campo obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                PUInput(
                                  hintText: 'Precio',
                                  controller: _.newpriceController,
                                  textInputType: TextInputType.number,
                                  validator: (price) {
                                    if (price?.isEmpty ?? false) {
                                      return 'Campo obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                PUInput(
                                  hintText: 'Tiempo de preparación (en minutos)',
                                  controller: _.newdeliveryController,
                                  textInputType: TextInputType.number,
                                  validator: (time) {
                                    if (time?.isEmpty ?? false) {
                                      return 'Campo obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                PuInputTags(
                                  hintText: 'Agrega los ingredientes',
                                  controller: _.tagIngredientsController,
                                  onSubmitTag: (tags) {
                                    _.updateIngredientsSelected(tags: tags);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          Column(
                            children: [
                              ButtonPrimary(
                                title: 'Crear',
                                onPressed: () async {
                                  if (keyFormCreateItem.currentState?.validate() ?? false) {
                                    if (_.fileTaked == null) {
                                      GlobalDialogsHandles.snackbarError(
                                        title: 'Logo obligatorio',
                                        message: 'Preferentemente PNG',
                                      );
                                      return;
                                    }
                                    _.menuSelected = dinning.menuSelected;
                                    _.update();
                                    await _.createMenuItemInServer();
                                    await dinning.getmenuByDining();
                                    Get.offAllNamed(PURoutes.HOME);
                                    return;
                                  }
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
                  ],
                ),
              ),
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
  final String? title;
  final bool? isLogo;
  final Uint8List? photoInBytes;
  const CardTakePhoto({
    super.key,
    this.onTaka,
    this.photoInBytes,
    this.isTaked,
    this.title,
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
          child: isTaked ?? false
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    photoInBytes!,
                    height: 130,
                    width: double.infinity,
                    fit: isLogo! ? BoxFit.contain : BoxFit.cover,
                  ),
                )
              : Container(
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
                      Text(
                        title ?? 'Cargá tu logo (.jpg, .png)',
                        style: PuTextStyle.textLabelMenu,
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }
}
