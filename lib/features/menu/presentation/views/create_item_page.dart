import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/widgets/card_take_photo.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';

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
  late final CatalogsController catalogsController;

  @override
  void initState() {
    super.initState();
    catalogsController = Get.find<CatalogsController>();
    catalogsController.loadCatalogsByType('menu');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CatalogsController>(
      builder: (catCtrl) {
        final selectedCatalog = catCtrl.catalogSelected.value;

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
                                    FluentIcons.arrow_left_24_regular,
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
                                  height:
                                      MediaQuery.of(context).size.width > 1000
                                          ? 80
                                          : 30,
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.isEditPage ?? false
                                              ? 'Editá tu producto'
                                              : 'Creá tu nuevo producto',
                                          textAlign: TextAlign.start,
                                          style: PuTextStyle.title1,
                                        ),
                                        Text(
                                          widget.isEditPage ?? false
                                              ? 'Renová tus ideas'
                                              : 'Deleitá a tus clientes',
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
                                  onTaka: () => catCtrl.pickImageDirectory(),
                                  photoInBytes:
                                      catCtrl.fileTaked ?? Uint8List(0),
                                  isTaked: catCtrl.fileTaked != null,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                PUInput(
                                  hintText: 'Nombre',
                                  controller: catCtrl.nameItemController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese un nombre';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                PUInput(
                                  hintText: 'Precio',
                                  controller: catCtrl.priceItemController,
                                  textInputType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese un precio';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                PUInput(
                                  hintText: 'Descripción',
                                  controller: catCtrl.descriptionItemController,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ButtonPrimary(
                                  title: widget.isEditPage ?? false
                                      ? 'Guardar'
                                      : 'Crear',
                                  onPressed: () async {
                                    if (keyFormCreateItem.currentState
                                            ?.validate() ??
                                        false) {
                                      if (catCtrl.fileTaked == null) {
                                        GlobalDialogsHandles.snackbarError(
                                          title: 'Logo obligatorio',
                                          message: 'Preferentemente PNG',
                                        );
                                        return;
                                      }

                                      CatalogItemModel? result;
                                      if (widget.isEditPage ?? false) {
                                        result =
                                            await catCtrl.editCatalogItem();
                                      } else {
                                        result =
                                            await catCtrl.createCatalogItem();
                                      }

                                      if (result != null) {
                                        await catCtrl
                                            .loadCatalogsByType('menu');
                                        Get.offNamed(PURoutes.HOME);
                                      }
                                    }
                                  },
                                  load: catCtrl.isLoadingItems.value,
                                ),
                                const SizedBox(
                                  height: 20,
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
        );
      },
    );
  }
}
