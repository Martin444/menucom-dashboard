import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

class CatalogSidebar extends StatelessWidget {
  final List<CatalogModel> catalogs;
  final CatalogModel? selected;
  final ValueChanged<CatalogModel> onSelect;
  final ValueChanged<CatalogModel> onEdit;
  final Future<void> Function(CatalogModel) onDelete;
  final VoidCallback? onAdd;
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
    this.onAdd,
    this.title = 'Mis catálogos',
    this.emptyMessage = 'No hay catálogos disponibles',
    required this.descriptionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: PuTextStyle.title1),
            if (onAdd != null)
              HeaderActionButton(
                icon: FluentIcons.add_24_regular,
                color: PUColors.primaryColor,
                onTap: onAdd!,
                tooltip: 'Nuevo catálogo',
              ),
          ],
        ),
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
