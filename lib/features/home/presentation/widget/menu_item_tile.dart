import 'package:flutter/material.dart';
import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_item_model.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class MenuItemTile extends StatelessWidget {
  final MenuItemModel item;
  final bool selected;
  final Function(MenuItemModel) onAddCart;
  final Function(MenuItemModel, String) actionSelected;
  const MenuItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onAddCart,
    required this.actionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onAddCart(item);
        },
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              decoration: PuStyleContainers.borderAllContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.network(
                    item.photoUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        PUOverflowTextDetector(
                          message: item.ingredients!.join(','),
                          children: [
                            Text(
                              item.ingredients!.join(','),
                              style: PuTextStyle.brandHeadStyle,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PUOverflowTextDetector(
                          message: item.name!,
                          children: [
                            Text(
                              item.name!,
                              style: PuTextStyle.nameProductStyle,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: PUOverflowTextDetector(
                                message: item.price!.toString().convertToCorrency(),
                                children: [
                                  Text(
                                    item.price!.toString().convertToCorrency(),
                                    style: PuTextStyle.nameProductStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton<String>(
                onSelected: (String result) {
                  if (result == 'settings') {
                    actionSelected(item, 'edit');
                  } else if (result == 'info') {
                    actionSelected(item, 'delete');
                  }
                },
                offset: const Offset(-140, 30),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.edit_rounded),
                      title: Text('Editar'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'info',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline_rounded),
                      title: Text('Eliminar'),
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert_rounded,
                  color: PUColors.iconColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
