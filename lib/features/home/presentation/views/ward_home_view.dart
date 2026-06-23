import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/catalog_unlinked_banners.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/catalog_sidebar.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class WardsHomeView extends StatefulWidget {
  const WardsHomeView({super.key, required this.isMobile});
  final bool isMobile;

  @override
  State<WardsHomeView> createState() => _WardsHomeViewState();
}

class _WardsHomeViewState extends State<WardsHomeView> with WidgetsBindingObserver {
  late final CatalogsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<CatalogsController>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadCatalogsByType('wardrobe');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _ctrl.loadCatalogsByType('wardrobe');
  }

  void _editCatalog(CatalogModel catalog) {
    _ctrl.changeCatalogSelected(catalog);
    _ctrl.gotoEditCatalog(catalog);
    Get.toNamed(PURoutes.EDIT_WARDROBES);
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
                    icon: FluentIcons.folder_24_regular,
                    actionButtons: [
                      HeaderActionButton(
                        icon: FluentIcons.add_24_regular,
                        color: PUColors.primaryColor,
                        onTap: () => Get.toNamed(PURoutes.REGISTER_WARDROBES),
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
                        child: Container(
                          padding: const EdgeInsets.only(top: 32, left: 24, bottom: 24).copyWith(
                            right: constraints.maxWidth > 1200 ? 24 : 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dashboard de Catálogos',
                                style: PuTextStyle.title1.copyWith(fontSize: 28, letterSpacing: -0.5)),
                              const SizedBox(height: 8),
                              Text('Gestiona tus productos y visualiza tu inventario de forma rápida y sencilla.',
                                style: PuTextStyle.bodyMedium.copyWith(color: const Color(0xFF475569))),
                              const SizedBox(height: 32),
                              Expanded(
                                child: catalogs.isEmpty
                                    ? CatalogEmptyState(onCreateCatalog: () => Get.toNamed(PURoutes.REGISTER_WARDROBES))
                                    : CatalogGridOrganism<CatalogItemModel>(
                                        constraints: constraints,
                                        items: selected?.items ?? [],
                                        emptyIcon: FluentIcons.folder_24_regular,
                                        emptyMessage: 'No hay productos en ${selected?.name ?? 'este catálogo'}',
                                        createButtonLabel: 'Cargar primer producto',
                                        onCreateItem: () => Get.toNamed(PURoutes.REGISTER_ITEM_WARDROBES),
                                        itemBuilder: (context, item, index) => WardItemTile(
                                          item: item,
                                          selected: false,
                                          onAddCart: (_) {},
                                          actionSelected: (_, action) async {
                                            if (action == 'edit') {
                                              _ctrl.gotoEditItem(item);
                                            } else if (action == 'delete') {
                                              await _ctrl.deleteCatalogItem(item);
                                              _ctrl.loadCatalogsByType('wardrobe');
                                            }
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (constraints.maxWidth > 1200)
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: constraints.maxHeight,
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 20, right: 16, top: 32),
                            decoration: BoxDecoration(
                              color: PUColors.bgItemMenuSelected.withOpacity(0.5),
                              border: Border(left: BorderSide(color: PUColors.primaryColor.withOpacity(0.05), width: 1)),
                            ),
                            child: CatalogSidebar(
                              catalogs: catalogs,
                              selected: selected,
                              onSelect: (c) => _ctrl.changeCatalogSelected(c),
                              onEdit: _editCatalog,
                              onDelete: _deleteCatalog,
                              onAdd: () => Get.toNamed(PURoutes.REGISTER_WARDROBES),
                              descriptionBuilder: (c) => c.name ?? '',
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
