import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_item_tile.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
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
    return GetBuilder<DinningController>(builder: (dinning) {
      if (dinning.menusList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return Scaffold(
        backgroundColor: PUColors.primaryBackground,
        drawerScrimColor: Colors.transparent,
        drawer: Drawer(
          backgroundColor: PUColors.bgItem.withOpacity(0.3),
          elevation: 0,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 60,
              sigmaY: 60,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Menu com',
                        style: PuTextStyle.title1,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ItemDrawMenu(
                        icon: Icons.home_outlined,
                        label: 'Inicio',
                        isSelected: true,
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: Icons.attach_money_outlined,
                        label: 'Ordenes',
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: Icons.attach_money_outlined,
                        label: 'Usuarios',
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: Icons.attach_money_outlined,
                        label: 'Ventas',
                        onRoute: () {},
                      ),
                    ],
                  ),
                  ItemDrawMenu(
                    icon: Icons.exit_to_app_outlined,
                    label: 'Cerrar sesión',
                    onRoute: () {
                      dinning.closeSesion();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  const BackgroundCircles(
                    withBlur: true,
                  ),
                  Column(
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
                                              SizedBox(
                                                width: 300,
                                                child: ButtonPrimary(
                                                  title: 'Agrega un plato',
                                                  onPressed: () {
                                                    Get.toNamed(
                                                      PURoutes
                                                          .REGISTER_ITEM_MENU,
                                                    );
                                                  },
                                                  load: false,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              SizedBox(
                                                height:
                                                    constrains.maxHeight - 80,
                                                child: GridView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: _.menusList[0]
                                                          .items?.length ??
                                                      0,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisExtent: 200,
                                                    childAspectRatio: 0.3,
                                                    crossAxisSpacing: 20,
                                                    mainAxisSpacing: 20,
                                                  ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return MenuItemTile(
                                                      item: _.menusList[0]
                                                          .items![index],
                                                      selected: _.menusList[0]
                                                              .items![index] ==
                                                          _.menusToEdit,
                                                      onAddCart: (menu) {
                                                        _.setDataToEditItem(
                                                            menu);
                                                      },
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
                                SizedBox(
                                  width: 20,
                                ),

                                // FOrmulario de edicion
                                Expanded(
                                  flex: 1,
                                  child: GetBuilder<DinningController>(
                                    builder: (_) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              PUColors.bgItem.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
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
                                                  height: 0,
                                                ),
                                                PUInput(
                                                  labelText: 'Nombre del plato',
                                                  controller: _.nameController,
                                                ),
                                                PUInput(
                                                  labelText: 'Precio',
                                                  controller: _.priceController,
                                                ),
                                                PUInput(
                                                  labelText:
                                                      'Tiempo de preparación (en minutos)',
                                                  controller:
                                                      _.deliveryController,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                ButtonPrimary(
                                                  title: 'Guardar cambios',
                                                  onPressed: () {
                                                    _.editItemMenu();
                                                  },
                                                  load: _.isEditProcess,
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
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ItemDrawMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool? isSelected;
  final Function onRoute;
  const ItemDrawMenu({
    super.key,
    required this.icon,
    this.isSelected,
    required this.label,
    required this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onRoute();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ?? false
                ? PUColors.secundaryBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: PUColors.primaryBackground,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                label,
                style: PuTextStyle.title3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
