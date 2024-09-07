import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/models/menu_model.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/get/menu_controller.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

import '../controllers/dinning_controller.dart';

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
                  Visibility(
                    visible: constrains.maxWidth < 1200,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 1,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PUColors.bgCategorySelected,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MenuModel>(
                          value: _.menuSelected,
                          items: _.menusList.map((MenuModel item) {
                            return DropdownMenuItem<MenuModel>(
                              value: item,
                              child: Text(item.description!),
                            );
                          }).toList(),
                          onChanged: (MenuModel? value) {},
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 8,
                          child: Container(
                            padding: const EdgeInsets.only(
                              right: 20,
                            ),
                            child: GridView.builder(
                              itemCount: 5,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: widget.isMobile ? 2 : 4,
                                // mainAxisExtent: 300,
                                mainAxisSpacing: 20,
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 20,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  color: Colors.red,
                                );
                              },
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
                                    'Mis menus',
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
                                          return menu.description!;
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
