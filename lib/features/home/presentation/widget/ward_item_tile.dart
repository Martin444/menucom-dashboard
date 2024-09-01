import 'package:flutter/material.dart';
import 'package:pickmeup_dashboard/features/wardrobes/model/clothing_item_model.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/formaters/currency_converter.dart';
import 'package:pu_material/utils/overflow_text.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

class WardItemTile extends StatelessWidget {
  final ClothingItemModel item;
  final bool selected;
  final Function(ClothingItemModel) onAddCart;
  const WardItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
          decoration: BoxDecoration(
            color: selected ? PUColors.selectedItem.withOpacity(0.5) : PUColors.bgItem.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Image.network(
              //   item.!,
              //   height: 120,
              //   width: double.infinity,
              //   fit: BoxFit.cover,
              // ),
              const SizedBox(
                height: 4,
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    PUOverflowTextDetector(
                      message: item.name,
                      children: [
                        Text(
                          item.name,
                          style: PuTextStyle.title3,
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
                            message: item.price.toString().convertToCorrency(),
                            children: [
                              Text('Hola'
                                  // item.price.toString().convertToCorrency(),
                                  // style: PuTextStyle.description1,
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
    );
  }
}
