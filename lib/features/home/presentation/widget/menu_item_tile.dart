import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

class MenuItemTile extends StatelessWidget {
  final CatalogItemModel item;
  final bool selected;
  final Function(CatalogItemModel) onAddCart;
  final Function(CatalogItemModel, String) actionSelected;
  const MenuItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onAddCart,
    required this.actionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProductCard(
          imageUrl: item.photoURL,
          title: item.name,
          price: item.price,
          primaryInfo: (item.tags ?? []).isNotEmpty ? (item.tags ?? []).join(', ') : null,
          isSelected: selected,
          onAddToCart: () => onAddCart(item),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: McOptionBtnTile(
            actionSelected: actionSelected,
            item: item,
          ),
        ),
      ],
    );
  }
}
