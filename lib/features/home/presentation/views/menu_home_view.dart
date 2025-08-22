import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_item_tile.dart';
import 'package:pickmeup_dashboard/features/menu/get/menu_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';

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
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PUColors.bgItem,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: PUColors.borderInputColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mis Menús',
                                style: PuTextStyle.title3.copyWith(
                                  fontSize: constrains.maxWidth < 600 ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // Action buttons for selected menu
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        menusController.gotoEditMenu(_.menuSelected);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: PUColors.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: SvgPicture.asset(
                                          PUIcons.iconEdit,
                                          width: 16,
                                          height: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Add more action buttons here if needed
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Menu Tags Grid
                          Wrap(
                            spacing: constrains.maxWidth < 600 ? 6 : 8,
                            runSpacing: constrains.maxWidth < 600 ? 6 : 8,
                            children: _.menusList.map((menu) {
                              final isSelected = _.menuSelected == menu;
                              final isSmallScreen = constrains.maxWidth < 600;

                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    _.chageMenuSelected(menu);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 12 : 16,
                                      vertical: isSmallScreen ? 8 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? PUColors.primaryColor : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? PUColors.primaryColor
                                            : PUColors.borderInputColor.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: PUColors.primaryColor.withOpacity(0.25),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Menu icon
                                        Icon(
                                          Icons.restaurant_menu,
                                          size: isSmallScreen ? 14 : 16,
                                          color: isSelected ? Colors.white : PUColors.iconColor,
                                        ),
                                        const SizedBox(width: 6),

                                        // Menu name
                                        Flexible(
                                          child: Text(
                                            menu.description ?? 'Sin nombre',
                                            style: PuTextStyle.description1.copyWith(
                                              fontSize: isSmallScreen ? 12 : 14,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                              color: isSelected ? Colors.white : PUColors.textColor3,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),

                                        // Item count badge
                                        if ((menu.items?.length ?? 0) > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withOpacity(0.2)
                                                  : PUColors.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${menu.items?.length ?? 0}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected ? Colors.white : PUColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
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
