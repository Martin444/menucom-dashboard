import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/category_tags_section.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/catalog_empty_state.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/catalog_grid.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
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

class _WardsHomeViewState extends State<WardsHomeView> with WidgetsBindingObserver {
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
    await catalogsController.loadCatalogsByType('wardrobe');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return GetBuilder<CatalogsController>(
          builder: (catCtrl) {
            debugPrint('=== WardsHomeView rebuild ===');
            debugPrint('catalogsList length: ${catCtrl.catalogsList.length}');
            debugPrint('catalogSelected: ${catCtrl.catalogSelected.value?.description}');
            debugPrint('catalogSelected items: ${catCtrl.catalogSelected.value?.items?.length ?? 0}');

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
                          selectedItem: selected ?? (catalogs.isNotEmpty ? catalogs.first : null),
                          onItemSelected: (catalog) => catCtrl.changeCatalogSelected(catalog),
                          descriptionBuilder: (catalog) => catalog.description ?? 'Sin nombre',
                          itemCountBuilder: (catalog) => catalog.itemCount,
                          constraints: constrains,
                          icon: FluentIcons.folder_24_regular,
                          onEditSelected: () {
                            final catalog = selected ?? (catalogs.isNotEmpty ? catalogs.first : null);
                            if (catalog != null) {
                              catCtrl.changeCatalogSelected(catalog);
                              catCtrl.gotoEditCatalog(catalog);
                              Get.toNamed(PURoutes.EDIT_WARDROBES);
                            }
                          },
                          onDeleteSelected: () async {
                            final catalog = selected ?? (catalogs.isNotEmpty ? catalogs.first : null);
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
                                  top: 32,
                                  left: 24,
                                  right: constrains.maxWidth > 1200 ? 24 : 0,
                                  bottom: 24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dashboard de Catálogos',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Gestiona tus productos y visualiza tu inventario de forma rápida y sencilla.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF475569),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Expanded(
                                      child: catalogs.isEmpty
                                          ? const CatalogEmptyState()
                                          : CatalogGrid(
                                              constraints: constrains,
                                              catCtrl: catCtrl,
                                              onReload: loadCatalogs,
                                            ),
                                    ),
                                  ],
                                ),
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
                                    left: 24,
                                    right: 16,
                                    top: 32,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    border: Border(
                                      left: BorderSide(
                                        color: Color(0xFFE2E8F0),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mis catálogos',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      if (catalogs.isEmpty)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 24.0),
                                            child: Text(
                                              'No hay catálogos disponibles',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF64748B),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ...catalogs.map(
                                        (element) {
                                          return ItemCategoryTile(
                                            item: element,
                                            isSelected: selected?.id == element.id,
                                            descriptionBuilder: (catalog) {
                                              return catalog.name ?? '';
                                            },
                                            onSelect: (catalog) {
                                              catCtrl.changeCatalogSelected(catalog);
                                            },
                                            onDelete: (catalog) async {
                                              await catCtrl.deleteCatalog(catalog);
                                            },
                                            onEdit: (catalog) {
                                              catCtrl.changeCatalogSelected(catalog);
                                              catCtrl.gotoEditCatalog(catalog);
                                              Get.toNamed(PURoutes.EDIT_WARDROBES);
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
}
