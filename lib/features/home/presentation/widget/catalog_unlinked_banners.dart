import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pu_material/pu_material.dart';

class CatalogUnlinkedBanners extends StatelessWidget {
  final CatalogsController controller;

  const CatalogUnlinkedBanners({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unlinked = controller.unlinkedCatalogs.toList();
      if (unlinked.isEmpty) return const SizedBox.shrink();
      final dinning = Get.find<DinningController>();
      if (dinning.currentUserRole.value != 'owner') return const SizedBox.shrink();
      return Column(
        children: unlinked
            .map((c) => UnlinkedCatalogsBanner(
                  catalog: c,
                  isLoading: controller.isAssigningCatalog.value,
                  onAssign: () => controller.assignCatalogToCommerce(c.id),
                ))
            .toList(),
      );
    });
  }
}
