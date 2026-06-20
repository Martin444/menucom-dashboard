import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pu_material/pu_material.dart';

class CatalogSidebar extends StatelessWidget {
  final List<CatalogModel> catalogs;
  final CatalogModel? selected;
  final ValueChanged<CatalogModel> onSelect;
  final ValueChanged<CatalogModel> onEdit;
  final Future<void> Function(CatalogModel) onDelete;
  final String title;
  final String emptyMessage;
  final String Function(CatalogModel) descriptionBuilder;

  const CatalogSidebar({
    super.key,
    required this.catalogs,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    this.title = 'Mis catálogos',
    this.emptyMessage = 'No hay catálogos disponibles',
    required this.descriptionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: PuTextStyle.title1),
        const SizedBox(height: 20),
        if (catalogs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(emptyMessage, style: PuTextStyle.description1, textAlign: TextAlign.center),
            ),
          ),
        ...catalogs.map((catalog) => ItemCategoryTile(
          item: catalog,
          isSelected: selected?.id == catalog.id,
          descriptionBuilder: descriptionBuilder,
          onSelect: (_) => onSelect(catalog),
          onDelete: (_) async => await onDelete(catalog),
          onEdit: (_) => onEdit(catalog),
        )),
      ],
    );
  }
}
