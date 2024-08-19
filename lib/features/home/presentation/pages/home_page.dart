import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/form_edit_side.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_item_tile.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';

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
    var isMobile = Get.width < 700;
    return GetBuilder<DinningController>(
      builder: (dinning) {
        if (dinning.isLoaginDataUser) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: PUColors.primaryBackground,
            drawerScrimColor: Colors.transparent,
            body: Row(
              children: [
                MenuSIde(),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Header
                          const HeadDinning(),

                          Container(
                            // height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color(0xFFBCBCBC),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      dinning.dinningLogin.name ?? '',
                                      style: PuTextStyle.title1,
                                    ),
                                    SvgPicture.asset(
                                      PUIcons.iconLink,
                                      colorFilter: ColorFilter.mode(
                                        PUColors.iconColor,
                                        BlendMode.src,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 200,
                                  child: ButtonPrimary(
                                    title: 'Nuevo menú',
                                    onPressed: () {
                                      Get.toNamed(
                                        PURoutes.REGISTER_ITEM_MENU,
                                      );
                                    },
                                    load: false,
                                  ),
                                ),
                              ],
                            ),
                          ),

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
                                  dinning.menusList.isNotEmpty
                                      ? Expanded(
                                          flex: 2,
                                          child: GetBuilder<DinningController>(
                                            builder: (_) {
                                              return LayoutBuilder(
                                                builder: (context, constrains) {
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      SizedBox(
                                                        width: 300,
                                                        child: ButtonPrimary(
                                                          title: 'Agrega un plato',
                                                          onPressed: () {
                                                            Get.toNamed(
                                                              PURoutes.REGISTER_ITEM_MENU,
                                                            );
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
                                                          itemCount: _.menusList[0].items?.length ?? 0,
                                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: isMobile ? 2 : 3,
                                                            mainAxisExtent: 200,
                                                            childAspectRatio: 0.3,
                                                            crossAxisSpacing: 20,
                                                            mainAxisSpacing: 20,
                                                          ),
                                                          itemBuilder: (context, index) {
                                                            return MenuItemTile(
                                                              item: _.menusList[0].items![index],
                                                              selected: _.menusList[0].items![index] == _.menusToEdit,
                                                              onAddCart: (menu) {
                                                                _.setDataToEditItem(
                                                                  menu,
                                                                );

                                                                if (isMobile) {
                                                                  Get.dialog(
                                                                    const Scaffold(
                                                                      body: FormEditSide(),
                                                                    ),
                                                                  );
                                                                }
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
                                        )
                                      : const Expanded(
                                          child: Center(
                                            child: Text('No hay items aún'),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class MenuSIde extends StatelessWidget {
  const MenuSIde({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return Drawer(
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
                vertical: 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Color(0xFFBCBCBC),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Image.network(
                        _.dinningLogin.photoURL!,
                        height: 100,
                        scale: 0.2,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconHomeMenu,
                        label: 'Inicio',
                        isSelected: false,
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconOrderMenu,
                        label: 'Ordenes',
                        isSelected: true,
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconSalesMenu,
                        label: 'Ventas',
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconClientsMenu,
                        label: 'Clientes',
                        onRoute: () {},
                      ),
                      ItemDrawMenu(
                        icon: PUIcons.iconProveeMenu,
                        label: 'Proveedores',
                        onRoute: () {},
                      ),
                    ],
                  ),
                  ItemDrawMenu(
                    icon: PUIcons.iconExitMenu,
                    label: 'Cerrar sesión',
                    onRoute: () {
                      _.closeSesion();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ItemDrawMenu extends StatelessWidget {
  final String icon;
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
            color: isSelected ?? false ? PUColors.bgItemMenuSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              SvgPicture.asset(icon),
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
