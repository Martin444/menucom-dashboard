import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:pu_material/widgets/inputs/pu_input.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/widgets/card_take_photo.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class CreateMenuPage extends StatefulWidget {
  final bool? isEditPage;

  const CreateMenuPage({
    super.key,
    this.isEditPage,
  });

  @override
  State<CreateMenuPage> createState() => _CreateMenuPageState();
}

class _CreateMenuPageState extends State<CreateMenuPage> {
  var dinningController = Get.find<DinningController>();
  late final CatalogsController catalogsController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CatalogsController>()) {
      catalogsController = Get.find<CatalogsController>();
    } else {
      catalogsController = Get.put(CatalogsController());
    }
    catalogsController.loadCatalogsByType('menu');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CatalogsController>(
      builder: (catCtrl) {
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
                                      FluentIcons.arrow_left_24_regular,
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
                                          ? 'Editá tu catálogo'
                                          : 'Creá tu nuevo catálogo',
                                      textAlign: TextAlign.start,
                                      style: PuTextStyle.title1,
                                    ),
                                    Text(
                                      widget.isEditPage ?? false
                                          ? 'Renová tus ideas'
                                          : 'Dejá que tu imaginación vuele',
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
                              controller: catCtrl.nameCatalog,
                            ),
                            const SizedBox(height: 20),
                            PUInput(
                              hintText: 'Descripción',
                              controller: catCtrl.descriptionCatalog,
                            ),
                            const SizedBox(height: 20),
                            CardTakePhoto(
                              onTaka: () => catCtrl.pickCoverImageCatalog(),
                              photoInBytes:
                                  catCtrl.coverImageCatalog ?? Uint8List(0),
                              isTaked: catCtrl.coverImageCatalog != null,
                              title: 'Cargá tu banner de catálogo (1200x400px)',
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text('¿Catálogo Público?',
                                    style: PuTextStyle.description1),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message:
                                      'Si es público, los usuarios lo van a poder ver en la landing de Menu.com',
                                  child: Icon(
                                    FluentIcons.info_24_regular,
                                    color: PUColors.textColor1,
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: catCtrl.isPublicCatalog,
                                  onChanged: (val) {
                                    catCtrl.changeIsPublicCatalog(val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ButtonPrimary(
                              title: widget.isEditPage ?? false
                                  ? 'Guardar'
                                  : 'Crear',
                              onPressed: () async {
                                if (widget.isEditPage ?? false) {
                                  final selected =
                                      catCtrl.catalogSelected.value;
                                  if (selected != null) {
                                    final result = await catCtrl.editCatalog(selected);
                                    if (result != null) {
                                      await catCtrl.loadCatalogsByType('menu');
                                      Get.offAllNamed(PURoutes.HOME);
                                    }
                                  }
                                  return;
                                }
                                final result = await catCtrl.createCatalog('menu');
                                if (result != null) {
                                  await catCtrl.loadCatalogsByType('menu');
                                  Get.offAllNamed(PURoutes.HOME);
                                }
                              },
                              load: catCtrl.isLoadingCatalogs.value,
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
