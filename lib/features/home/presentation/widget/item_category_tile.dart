import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';

class ItemCategoryTile<T> extends StatelessWidget {
  final T? item;
  final Function(T)? onEdit;
  final Function(T)? onDelete;
  final String Function(T)? descriptionBuilder;

  const ItemCategoryTile({
    super.key,
    required this.item,
    required this.descriptionBuilder,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: PUColors.bgCategorySelected,
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
                  child: SvgPicture.asset(
                    PUIcons.iconEdit,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  onDelete!(item as T);
                },
                child: SvgPicture.asset(
                  PUIcons.iconDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
