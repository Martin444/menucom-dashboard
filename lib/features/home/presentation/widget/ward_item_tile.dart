import 'package:flutter/material.dart';
import 'package:menu_dart_api/by_feature/wardrobe/get_me_wardrobe/model/clothing_item_model.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/pu_material.dart';

class WardItemTile extends StatelessWidget {
  final ClothingItemModel item;
  final bool selected;
  final Function(ClothingItemModel) onAddCart;
  final Function(ClothingItemModel, String) actionSelected;
  const WardItemTile({
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
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              onAddCart(item);
            },
            child: Container(
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
                  PuRobustNetworkImage(
                    imageUrl: item.photoURL!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        PUOverflowTextDetector(
                          message: item.sizes!.join(','),
                          children: [
                            Text(
                              item.sizes!.join(','),
                              style: PuTextStyle.brandHeadStyle,
                            ),
                          ],
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
          ),
        ),
        McOptionBtnTile(actionSelected: actionSelected, item: item),
      ],
    );
  }
}
