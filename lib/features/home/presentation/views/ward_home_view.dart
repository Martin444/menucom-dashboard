import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/wardrobe/get_me_wardrobe/model/wardrobe_model.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/category_tags_section.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/ward_item_tile.dart';
import 'package:pickmeup_dashboard/features/wardrobes/getx/wardrobes_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/widgets/buttons/button_primary.dart';
import 'package:svg_flutter/svg.dart';

import '../../controllers/dinning_controller.dart';

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
                    child: CategoryTagsSection<WardrobeModel>(
                      title: 'Mis Guardarropas',
                      items: _.wardList,
                      selectedItem: _.wardSelected,
                      onItemSelected: (wardrobe) => _.chageWardSelected(wardrobe),
                      descriptionBuilder: (wardrobe) => wardrobe.description ?? 'Sin nombre',
                      itemCountBuilder: (wardrobe) => wardrobe.items?.length ?? 0,
                      constrains: constrains,
                      icon: Icons.checkroom,
                      onEditSelected: () => wardController.gotoEditWardrobe(_.wardSelected),
                      onDeleteSelected: () async {
                        await wardController.deleteWardrobe(_.wardSelected);
                        _.getmenuByDining();
                      },
                      emptyMessage: 'No hay guardarropas disponibles',
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
                            child: _.wardSelected.items?.isNotEmpty ?? false
                                ? GridView.builder(
                                    itemCount: _.wardSelected.items?.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: constrains.maxWidth < 800
                                          ? constrains.maxWidth > 600
                                              ? 3
                                              : 2
                                          : 4,
                                      mainAxisExtent: 330,
                                      mainAxisSpacing: 0,
                                      childAspectRatio: 1.0,
                                      crossAxisSpacing: 0,
                                    ),
                                    itemBuilder: (context, index) {
                                      return WardItemTile(
                                        item: _.wardSelected.items![index],
                                        selected: false,
                                        onAddCart: (val) {},
                                        actionSelected: (item, action) async {
                                          if (action == 'delete') {
                                            await wardController.deleteItemClothing(item);
                                            _.getWardrobebyDining();
                                          }

                                          if (action == 'edit') {
                                            wardController.goToEditClothing(item);
                                          }
                                        },
                                      );
                                    },
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        PUImages.noDataImageSvg,
                                        height: 140,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Center(
                                        child: Text(
                                          'No hay prendas cargadas para ${_.wardSelected.description ?? '-'}',
                                          style: PuTextStyle.description1,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 300,
                                        ),
                                        child: ButtonPrimary(
                                          title: 'Cargar primera prenda',
                                          onPressed: () {
                                            Get.toNamed(PURoutes.REGISTER_ITEM_WARDROBES);
                                          },
                                          load: false,
                                        ),
                                      ),
                                    ],
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
