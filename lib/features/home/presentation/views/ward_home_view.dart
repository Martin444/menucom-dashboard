import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/category_tags_section.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/ward_item_tile.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/pu_material.dart';

import '../../controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class WardsHomeView extends StatefulWidget {
  const WardsHomeView({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  State<WardsHomeView> createState() => _WardsHomeViewState();
}

class _WardsHomeViewState extends State<WardsHomeView> {
  final catalogsController = Get.put(CatalogsController());

  @override
  void initState() {
    super.initState();
    loadCatalogs();
  }

  Future<void> loadCatalogs() async {
    await catalogsController.loadCatalogsByType('wardrobe');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return GetBuilder<CatalogsController>(
          builder: (catCtrl) {
            final catalogs = catCtrl.catalogsList.toList();
            final selected = catCtrl.catalogSelected.value;

            return LayoutBuilder(
              builder: (context, constrains) {
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
                          selectedItem: selected ??
                              (catalogs.isNotEmpty
                                  ? catalogs.first
                                  : null),
                          onItemSelected: (catalog) =>
                              catCtrl.changeCatalogSelected(catalog),
                          descriptionBuilder: (catalog) =>
                              catalog.description ?? 'Sin nombre',
                          itemCountBuilder: (catalog) => catalog.itemCount,
                          constrains: constrains,
                          icon: FluentIcons.folder_24_regular,
                          onEditSelected: () {
                            final catalog = selected ??
                                (catalogs.isNotEmpty ? catalogs.first : null);
                            if (catalog != null) {
                              catCtrl.changeCatalogSelected(catalog);
                              catCtrl.gotoEditCatalog(catalog);
                              Get.toNamed(PURoutes.EDIT_WARDROBES);
                            }
                          },
                          onDeleteSelected: () async {
                            final catalog = selected ??
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
                                    ? _buildEmptyState()
                                    : _buildCatalogGrid(constrains, catCtrl),
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
                                      ...catalogs.map(
                                        (element) {
                                          return ItemCategoryTile(
                                            item: element,
                                            isSelected:
                                                selected?.id == element.id,
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
                                                  PURoutes.EDIT_WARDROBES);
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

  Widget _buildEmptyState() {
    return Column(
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
            'No hay catálogos disponibles',
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
            title: 'Crear primer catálogo',
            onPressed: () async {
              await catalogsController.createCatalog('wardrobe');
            },
            load: false,
          ),
        ),
      ],
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
          SvgPicture.asset(
            PUImages.noDataImageSvg,
            height: 140,
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
        return WardItemTile(
          item: _convertCatalogItemToClothingItem(item),
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

  ClothingItemModel _convertCatalogItemToClothingItem(CatalogItemModel item) {
    return ClothingItemModel(
      id: item.id,
      name: item.name,
      photoURL: item.photoURL,
      price: item.price,
      sizes: item.tags,
      brand: item.description,
    );
  }
}
