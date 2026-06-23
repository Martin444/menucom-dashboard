import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/catalog_unlinked_banners.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/catalog_sidebar.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class MenuHomeView extends StatefulWidget {
  const MenuHomeView({super.key, required this.isMobile});
  final bool isMobile;

  @override
  State<MenuHomeView> createState() => _MenuHomeViewState();
}

class _MenuHomeViewState extends State<MenuHomeView> with WidgetsBindingObserver {
  late final CatalogsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<CatalogsController>();
    WidgetsBinding.instance.addObserver(this);
    _ctrl.loadCatalogsByType('menu');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _ctrl.loadCatalogsByType('menu');
  }

  void _editCatalog(CatalogModel catalog) {
    _ctrl.changeCatalogSelected(catalog);
    _ctrl.gotoEditCatalog(catalog);
    Get.toNamed(PURoutes.EDIT_MENU_CATEGORY);
  }

  Future<void> _deleteCatalog(CatalogModel catalog) async {
    await _ctrl.deleteCatalog(catalog);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CatalogsController>(
      builder: (_) {
        final catalogs = _.catalogsList.toList();
        final selected = _.catalogSelected.value;

        return LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatalogUnlinkedBanners(controller: _ctrl),
                if (constraints.maxWidth < 1200)
                  CategoryTagsSection<CatalogModel>(
                    title: 'Mis Catálogos',
                    items: catalogs,
                    selectedItem: selected ?? (catalogs.isNotEmpty ? catalogs.first : null),
                    onItemSelected: (c) => _ctrl.changeCatalogSelected(c),
                    descriptionBuilder: (c) => c.description ?? 'Sin nombre',
                    itemCountBuilder: (c) => c.itemCount,
                    constraints: constraints,
                    icon: FluentIcons.food_24_regular,
                    actionButtons: [
                      HeaderActionButton(
                        icon: FluentIcons.add_24_regular,
                        color: PUColors.primaryColor,
                        onTap: () => Get.toNamed(PURoutes.REGISTER_MENU_CATEGORY),
                        tooltip: 'Nuevo catálogo',
                      ),
                    ],
                    onEditSelected: () {
                      final c = selected ?? (catalogs.isNotEmpty ? catalogs.first : null);
                      if (c != null) _editCatalog(c);
                    },
                    onDeleteSelected: () async {
                      final c = selected ?? (catalogs.isNotEmpty ? catalogs.first : null);
                      if (c != null) await _deleteCatalog(c);
                    },
                    emptyMessage: 'No hay catálogos disponibles',
                  ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: EdgeInsets.only(right: constraints.maxWidth > 1200 ? 20 : 0),
                          child: catalogs.isEmpty
                              ? CatalogEmptyState(onCreateCatalog: () => Get.toNamed(PURoutes.REGISTER_MENU_CATEGORY))
                              : CatalogGridOrganism<CatalogItemModel>(
                                  constraints: constraints,
                                  items: selected?.items ?? [],
                                  emptyIcon: FluentIcons.food_24_regular,
                                  emptyMessage: 'No hay productos en ${selected?.description ?? 'este catálogo'}',
                                  createButtonLabel: 'Cargar primer producto',
                                  onCreateItem: () => Get.toNamed(PURoutes.REGISTER_ITEM_MENU),
                                  itemBuilder: (context, item, index) => MenuItemTile(
                                    item: item,
                                    selected: false,
                                    onAddCart: (_) {},
                                    actionSelected: (_, action) async {
                                      if (action == 'edit') {
                                        _ctrl.gotoEditItem(item);
                                      } else if (action == 'delete') {
                                        await _ctrl.deleteCatalogItem(item);
                                        _ctrl.loadCatalogsByType('menu');
                                      }
                                    },
                                  ),
                                ),
                        ),
                      ),
                      if (constraints.maxWidth > 1200)
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: constraints.maxHeight,
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 20),
                            decoration: PuStyleContainers.borderLeftContainer,
                            child: CatalogSidebar(
                              catalogs: catalogs,
                              selected: selected,
                              onSelect: (c) => _ctrl.changeCatalogSelected(c),
                              onEdit: _editCatalog,
                              onDelete: _deleteCatalog,
                              onAdd: () => Get.toNamed(PURoutes.REGISTER_MENU_CATEGORY),
                              descriptionBuilder: (c) => c.description ?? '',
                            ),
                          ),
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
