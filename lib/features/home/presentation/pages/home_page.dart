import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/models/menu_item_model.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_item_tile.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

import '../widget/head_dinning.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var dinninController = Get.find<DinningController>();

  @override
  void initState() {
    dinninController.getMyDinningInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var heigthMax = MediaQuery.of(context).size.height;
    return GetBuilder<DinningController>(builder: (dinning) {
      if (dinning.menusList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 210,
              height: heigthMax,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: PUColors.primaryColor,
              ),
              child: Column(
                children: [
                  Image.asset(PUImages.dashLogo),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Header
                  const HeadDinning(),

                  // Seccion de items del menú
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        color: PUColors.primaryBackground,
                        child: Row(
                          children: [
                            // items
                            Expanded(
                              flex: 2,
                              child: GetBuilder<DinningController>(
                                builder: (_) {
                                  return LayoutBuilder(
                                    builder: (context, constrains) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 300,
                                            child: ButtonPrimary(
                                              title: 'Agrega un plato',
                                              onPressed: () {
                                                Get.toNamed(PURoutes
                                                    .REGISTER_ITEM_MENU);
                                              },
                                              load: false,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          SizedBox(
                                            height: constrains.maxHeight - 80,
                                            child: GridView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: _.menusList[0].items
                                                      ?.length ??
                                                  0,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                mainAxisExtent: 200,
                                                childAspectRatio: 0.3,
                                                crossAxisSpacing: 20,
                                                mainAxisSpacing: 20,
                                              ),
                                              itemBuilder: (context, index) {
                                                return MenuItemTile(
                                                  item: _.menusList[0]
                                                      .items![index],
                                                  selected: _.menusList[0]
                                                          .items![index] ==
                                                      _.menusToEdit,
                                                  onAddCart: (p0) {},
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              color: PUColors.textColor1,
                            ),
                            // FOrmulario de edicion
                            Expanded(
                              flex: 1,
                              child: GetBuilder<DinningController>(
                                builder: (_) {
                                  return Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Edita tu plato en el menu del dia',
                                              style: PuTextStyle.title3,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Image.network(
                                              _.photoController,
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            PUInput(
                                              labelText: 'Nombre del plato',
                                              controller: _.nameController,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            PUInput(
                                              labelText: 'Precio',
                                              controller: _.priceController,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            PUInput(
                                              labelText:
                                                  'Tiempo de preparación (en minutos)',
                                              controller: _.deliveryController,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            ButtonPrimary(
                                              title: 'Guardar cambios',
                                              onPressed: () {},
                                              load: false,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
