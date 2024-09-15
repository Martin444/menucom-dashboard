import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/wardrobes/presentation/getx/wardrobes_controller.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

import '../../../wardrobes/model/wardrobe_model.dart';
import '../controllers/dinning_controller.dart';

class WardsHomeView extends StatefulWidget {
  const WardsHomeView({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  State<WardsHomeView> createState() => _WardsHomeViewState();
}

class _WardsHomeViewState extends State<WardsHomeView> {
  var wardController = Get.find<WardrobesController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DinningController>(
      builder: (_) {
        return LayoutBuilder(
          builder: (context, constrains) {
            return SizedBox(
              height: constrains.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: constrains.maxWidth < 1200,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PUColors.bgCategorySelected,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<WardrobeModel>(
                          value: _.wardSelected,
                          items: _.wardList.map((WardrobeModel item) {
                            return DropdownMenuItem<WardrobeModel>(
                              value: item,
                              child: Text(item.description!),
                            );
                          }).toList(),
                          onChanged: (WardrobeModel? value) {
                            _.chageWardSelected(value!);
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 8,
                          child: Container(
                            padding: const EdgeInsets.only(
                              right: 20,
                            ),
                            child: GridView.builder(
                              itemCount: 5,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: widget.isMobile ? 2 : 4,
                                // mainAxisExtent: 300,
                                mainAxisSpacing: 20,
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 20,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  color: Colors.red,
                                );
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: constrains.maxWidth > 1200,
                          child: Flexible(
                            flex: 2,
                            child: Container(
                              height: constrains.maxHeight,
                              padding: const EdgeInsets.only(
                                left: 20,
                              ),
                              decoration: PuStyleContainers.borderLeftContainer,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mis guardarropas',
                                    style: PuTextStyle.title1,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ..._.wardList.map(
                                    (element) {
                                      return ItemCategoryTile(
                                        item: element,
                                        isSelected: _.wardSelected == element,
                                        descriptionBuilder: (ward) {
                                          return ward.description!;
                                        },
                                        onSelect: (ward) {
                                          _.chageWardSelected(ward);
                                        },
                                        onDelete: (ward) async {
                                          _.chageWardSelected(ward);
                                          await wardController.deleteWardrobe(ward);
                                          _.getWardrobebyDining();
                                        },
                                        onEdit: (ward) {
                                          _.chageWardSelected(ward);
                                          wardController.gotoEditWardrobe(ward);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}