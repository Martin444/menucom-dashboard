import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/organisms/unlinked_catalogs_banner.dart';

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
            .map((c) => UnlinkedCatalogsBanner(catalog: c, controller: controller))
            .toList(),
      );
    });
  }
}
