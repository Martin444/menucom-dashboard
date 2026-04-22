import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/ward_item_tile.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class CatalogGrid extends StatelessWidget {
  final BoxConstraints constraints;
  final CatalogsController catCtrl;
  final VoidCallback onReload;

  const CatalogGrid({
    super.key,
    required this.constraints,
    required this.catCtrl,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = catCtrl.catalogSelected.value;
      final items = selected?.items ?? [];

      if (items.isEmpty) {
        return Column(
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
                'No hay productos en ${selected?.name ?? 'este catálogo'}',
                style: PuTextStyle.description1,
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
                title: 'Cargar primer producto',
                onPressed: () {
                  Get.toNamed(PURoutes.REGISTER_ITEM_WARDROBES);
                },
                load: false,
              ),
            ),
          ],
        );
      }

      return GridView.builder(
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth >= 1024
              ? 4
              : constraints.maxWidth >= 768
                  ? 3
                  : 2,
          mainAxisExtent: 330,
          mainAxisSpacing: 0,
          childAspectRatio: 1.0,
          crossAxisSpacing: 0,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return WardItemTile(
            item: item,
            selected: false,
            onAddCart: (val) {},
            actionSelected: (value, action) async {
              if (action == 'edit') {
                catCtrl.gotoEditItem(item);
              } else if (action == 'delete') {
                await catCtrl.deleteCatalogItem(item);
                onReload();
              }
            },
          );
        },
      );
    });
  }
}
