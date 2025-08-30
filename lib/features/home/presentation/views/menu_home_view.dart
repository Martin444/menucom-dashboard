import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/category_tags_section.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_item_tile.dart';
import 'package:pickmeup_dashboard/features/menu/get/menu_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../controllers/dinning_controller.dart';

class MenuHomeView extends StatefulWidget {
  const MenuHomeView({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  State<MenuHomeView> createState() => _MenuHomeViewState();
}

class _MenuHomeViewState extends State<MenuHomeView> {
  var menusController = Get.find<MenusController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return LayoutBuilder(
          builder: (context, constrains) {
            return SizedBox(
              height: constrains.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Tags Section - Responsive
                  Visibility(
                    visible: constrains.maxWidth < 1200,
                    child: CategoryTagsSection<MenuModel>(
                      title: 'Mis Menús',
                      items: _.menusList,
                      selectedItem: _.menuSelected,
                      onItemSelected: (menu) => _.chageMenuSelected(menu),
                      descriptionBuilder: (menu) => menu.description ?? 'Sin nombre',
                      itemCountBuilder: (menu) => menu.items?.length ?? 0,
                      constrains: constrains,
                      icon: FluentIcons.food_24_regular,
                      onEditSelected: () => menusController.gotoEditMenu(_.menuSelected),
                      emptyMessage: 'No hay menús disponibles',
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Container(
                            padding: EdgeInsets.only(
                              right: constrains.maxWidth > 1200 ? 20 : 0,
                            ),
                            child: _.menuSelected.items?.isNotEmpty ?? false
                                ? GridView.builder(
                                    itemCount: _.menuSelected.items?.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: constrains.maxWidth < 800
                                          ? constrains.maxWidth > 600
                                              ? 3
                                              : 2
                                          : 4,
                                      mainAxisExtent: 330,
                                      mainAxisSpacing: 0,
                                      childAspectRatio: 1.0,
                                      crossAxisSpacing: 0,
                                    ),
                                    itemBuilder: (context, index) {
                                      return MenuItemTile(
                                        item: _.menuSelected.items![index],
                                        selected: false,
                                        onAddCart: (val) {},
                                        actionSelected: (value, action) async {
                                          if (action == 'edit') {
                                            menusController.gotoEditItemMenu(value);
                                          } else if (action == 'delete') {
                                            await menusController.deleteItemMenu(value);
                                            _.getmenuByDining();
                                          }
                                        },
                                      );
                                    },
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        PUImages.noDataImageSvg,
                                        height: 140,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Center(
                                        child: Text(
                                          'No hay ningun plato cargado para ${_.menuSelected.description ?? '-'}',
                                          style: PuTextStyle.description1,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 300,
                                        ),
                                        child: ButtonPrimary(
                                          title: 'Cargar primer plato',
                                          onPressed: () {
                                            Get.toNamed(PURoutes.REGISTER_ITEM_MENU);
                                          },
                                          load: false,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        Visibility(
                          visible: constrains.maxWidth > 1200,
                          child: Flexible(
                            flex: 2,
                            child: Container(
                              height: constrains.maxHeight,
                              padding: const EdgeInsets.only(
                                left: 20,
                              ),
                              decoration: PuStyleContainers.borderLeftContainer,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mis menús',
                                    style: PuTextStyle.title1,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ..._.menusList.map(
                                    (element) {
                                      return ItemCategoryTile(
                                        item: element,
                                        isSelected: _.menuSelected == element,
                                        descriptionBuilder: (menu) {
                                          return menu.description ?? '';
                                        },
                                        onSelect: (menu) {
                                          _.chageMenuSelected(menu);
                                        },
                                        onDelete: (menu) async {
                                          _.chageMenuSelected(menu);
                                          // _.chagemenuSelected(menu);
                                          await menusController.deleteMenus(menu);
                                          _.getmenuByDining();
                                        },
                                        onEdit: (menu) {
                                          _.chageMenuSelected(menu);
                                          menusController.gotoEditMenu(menu);
                                          // _.chageWardSelected(ward);
                                          // wardController.gotoEditWardrobe(ward);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
