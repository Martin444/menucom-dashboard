import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class ItemCategoryTile<T> extends StatelessWidget {
  final T? item;
  final Function(T)? onEdit;
  final Function(T)? onDelete;
  final Function(T)? onSelect;
  final bool? isSelected;
  final String Function(T)? descriptionBuilder;

  const ItemCategoryTile({
    super.key,
    required this.item,
    required this.descriptionBuilder,
    this.onEdit,
    this.onSelect,
    this.isSelected,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect!(item as T);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ?? false ? PUColors.bgCategorySelected : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              descriptionBuilder!(item as T),
              style: PuTextStyle.textbtnStyle,
            ),
            Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      onEdit!(item as T);
                    },
                    child: Icon(
                      FluentIcons.edit_24_regular,
                      size: 20,
                      color: PUColors.primaryColor,
                    ),
                  ),
                ),
                //El boton de borrar solo se debe mostrar si el usuario tiene permisos
                // MouseRegion(
                //   cursor: SystemMouseCursors.click,
                //   child: GestureDetector(
                //     onTap: () {
                //       onDelete!(item as T);
                //     },
                //     child: Icon(
                //       FluentIcons.delete_24_regular,
                //       size: 20,
                //       color: Colors.red,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
