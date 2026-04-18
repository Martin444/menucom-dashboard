import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/category_tags_section.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_item_tile.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';

import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/catalog_empty_state.dart';

import '../../controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class MenuHomeView extends StatefulWidget {
  const MenuHomeView({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  State<MenuHomeView> createState() => _MenuHomeViewState();
}

class _MenuHomeViewState extends State<MenuHomeView>
    with WidgetsBindingObserver {
  late final CatalogsController catalogsController;

  @override
  void initState() {
    super.initState();
    catalogsController = Get.find<CatalogsController>();
    WidgetsBinding.instance.addObserver(this);
    loadCatalogs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadCatalogs();
    }
  }

  Future<void> loadCatalogs() async {
    await catalogsController.loadCatalogsByType('menu');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return GetBuilder<CatalogsController>(
          builder: (catCtrl) {
            debugPrint('=== MenuHomeView rebuild ===');
            debugPrint('catalogsList length: ${catCtrl.catalogsList.length}');
            debugPrint(
                'catalogSelected: ${catCtrl.catalogSelected.value?.description}');
            debugPrint(
                'catalogSelected items: ${catCtrl.catalogSelected.value?.items?.length ?? 0}');

            return LayoutBuilder(
              builder: (context, constrains) {
                final catalogs = catCtrl.catalogsList.toList();
                CatalogModel? selectedCatalog;
                if (catCtrl.catalogSelected.value != null) {
                  selectedCatalog = catCtrl.catalogSelected.value;
                }

                return SizedBox(
                  height: constrains.maxHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: constrains.maxWidth < 1200,
                        child: CategoryTagsSection<CatalogModel>(
                          title: 'Mis Catálogos',
                          items: catalogs,
                          selectedItem: selectedCatalog ??
                              (catalogs.isNotEmpty ? catalogs.first : null),
                          onItemSelected: (catalog) =>
                              catCtrl.changeCatalogSelected(catalog),
                          descriptionBuilder: (catalog) =>
                              catalog.description ?? 'Sin nombre',
                          itemCountBuilder: (catalog) => catalog.itemCount,
                          constraints: constrains,
                          icon: FluentIcons.food_24_regular,
                          onEditSelected: () {
                            final catalog = selectedCatalog ??
                                (catalogs.isNotEmpty ? catalogs.first : null);
                            if (catalog != null) {
                              catCtrl.changeCatalogSelected(catalog);
                              catCtrl.gotoEditCatalog(catalog);
                              Get.toNamed(PURoutes.EDIT_MENU_CATEGORY);
                            }
                          },
                          onDeleteSelected: () async {
                            final catalog = selectedCatalog ??
                                (catalogs.isNotEmpty ? catalogs.first : null);
                            if (catalog != null) {
                              await catCtrl.deleteCatalog(catalog);
                            }
                          },
                          emptyMessage: 'No hay catálogos disponibles',
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
                                child: catalogs.isEmpty
                                    ? const CatalogEmptyState()
                                    : _buildCatalogGrid(constrains, catCtrl),
                              ),
                            ),
                            Visibility(
                              visible: constrains.maxWidth > 1200,
                              child: Expanded(
                                flex: 2,
                                child: Container(
                                  height: constrains.maxHeight,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                  ),
                                  decoration:
                                      PuStyleContainers.borderLeftContainer,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mis catálogos',
                                        style: PuTextStyle.title1,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      if (catalogs.isEmpty)
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 24.0),
                                            child: Text(
                                              'No hay catálogos disponibles',
                                              style: PuTextStyle.description1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ...catalogs.map(
                                        (element) {
                                          return ItemCategoryTile(
                                            item: element,
                                            isSelected: selectedCatalog?.id ==
                                                element.id,
                                            descriptionBuilder: (catalog) {
                                              return catalog.description ?? '';
                                            },
                                            onSelect: (catalog) {
                                              catCtrl.changeCatalogSelected(
                                                  catalog);
                                            },
                                            onDelete: (catalog) async {
                                              await catCtrl
                                                  .deleteCatalog(catalog);
                                            },
                                            onEdit: (catalog) {
                                              catCtrl.changeCatalogSelected(
                                                  catalog);
                                              catCtrl.gotoEditCatalog(catalog);
                                              Get.toNamed(
                                                  PURoutes.EDIT_MENU_CATEGORY);
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
      },
    );
  }


  Widget _buildCatalogGrid(
      BoxConstraints constrains, CatalogsController catCtrl) {
    final selected = catCtrl.catalogSelected.value;
    final items = selected?.items ?? [];

    if (items.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            PUImages.noDataImageSvg,
            height: 140,
            errorBuilder: (context, error, stackTrace) => Icon(
              FluentIcons.food_24_regular,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              'No hay productos en ${selected?.description ?? 'este catálogo'}',
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
              title: 'Cargar primer producto',
              onPressed: () {},
              load: false,
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      itemCount: items.length,
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
        final item = items[index];
        return MenuItemTile(
          item: _convertCatalogItemToMenuItem(item),
          selected: false,
          onAddCart: (val) {},
          actionSelected: (value, action) async {
            if (action == 'edit') {
              catCtrl.gotoEditItem(item);
            } else if (action == 'delete') {
              await catCtrl.deleteCatalogItem(item);
              loadCatalogs();
            }
          },
        );
      },
    );
  }

  MenuItemModel _convertCatalogItemToMenuItem(CatalogItemModel item) {
    return MenuItemModel(
      id: item.id,
      name: item.name,
      photoUrl: item.photoURL,
      price: item.price,
      ingredients: item.tags,
      description: item.description,
    );
  }
}
