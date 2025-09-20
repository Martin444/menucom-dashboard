import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/wardrobe/get_me_wardrobe/model/wardrobe_model.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/category_tags_section.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/item_category_tile.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/ward_item_tile.dart';
import 'package:pickmeup_dashboard/features/wardrobes/getx/wardrobes_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pu_material/pu_material.dart';

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
        // Debug: Verificar la lista de guardarropas
        debugPrint('=== DEBUG WardsHomeView ===');
        debugPrint('wardList length: ${_.wardList.length}');
        for (int i = 0; i < _.wardList.length; i++) {
          debugPrint('Ward $i: ${_.wardList[i].description} (ID: ${_.wardList[i].id})');
        }
        debugPrint('wardSelected: ${_.wardSelected.description} (ID: ${_.wardSelected.id})');

        return LayoutBuilder(
          builder: (context, constrains) {
            // Debug: Verificar las dimensiones
            debugPrint('Screen width: ${constrains.maxWidth}');
            debugPrint('Will show CategoryTagsSection: ${constrains.maxWidth < 1200}');
            debugPrint('Will show CategorySidebar: ${constrains.maxWidth > 1200}');
            return WardsHomeOrganism<WardrobeModel, dynamic>(
              constraints: constrains,
              isMobile: widget.isMobile,
              // Categories (wardrobes)
              categories: _.wardList,
              selectedCategory: _.wardSelected,
              categoryTitleBuilder: (wardrobe) => wardrobe.description ?? 'Sin nombre',
              onCategorySelected: (wardrobe) => _.chageWardSelected(wardrobe),
              categoriesTitle: 'Mis guardarropas',
              categoryTileBuilder: (wardrobe) => ItemCategoryTile(
                item: wardrobe,
                isSelected: _.wardSelected == wardrobe,
                descriptionBuilder: (ward) => ward.description!,
                onSelect: (ward) => _.chageWardSelected(ward),
                onDelete: (ward) async {
                  _.chageWardSelected(ward);
                  await wardController.deleteWardrobe(ward);
                  _.getWardrobebyDining();
                },
                onEdit: (ward) {
                  _.chageWardSelected(ward);
                  wardController.gotoEditWardrobe(ward);
                },
              ),
              // Items
              items: _.wardSelected.items ?? [],
              itemBuilder: (item, index) => WardItemTile(
                item: item,
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
              ),
              emptyItemsTitle: 'No hay prendas cargadas para ${_.wardSelected.description ?? '-'}',
              emptyItemsImagePath: PUImages.noDataImageSvg,
              emptyItemsButtonText: 'Cargar primera prenda',
              onEmptyItemsButtonPressed: () {
                Get.toNamed(PURoutes.REGISTER_ITEM_WARDROBES);
              },
              // Promo card configuration
              showPromoCard: true,
              promoTitle: 'Creá categorías ilimitadas y tomá el control de tu stock.',
              promoButtonText: 'Comenzá con premium',
              onPromoButtonTap: () {
                // Lógica para activar premium
                debugPrint('Premium activado para guardarropas');
                // Aquí puedes agregar navegación o mostrar un diálogo
              },
              // Tags section for mobile
              tagsSection: CategoryTagsSection<WardrobeModel>(
                title: 'Mis Guardarropas',
                items: _.wardList,
                selectedItem: _.wardSelected,
                onItemSelected: (wardrobe) => _.chageWardSelected(wardrobe),
                descriptionBuilder: (wardrobe) => wardrobe.description ?? 'Sin nombre',
                itemCountBuilder: (wardrobe) => wardrobe.items?.length ?? 0,
                constrains: constrains,
                icon: FluentIcons.folder_24_regular,
                onEditSelected: () => wardController.gotoEditWardrobe(_.wardSelected),
                emptyMessage: 'No hay guardarropas disponibles',
              ),
            );
          },
        );
      },
    );
  }
}
