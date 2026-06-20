import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pu_material/pu_material.dart';

import '../../../catalogs/getx/catalogs_controller.dart';

class UnlinkedCatalogsBanner extends StatelessWidget {
  const UnlinkedCatalogsBanner({
    super.key,
    required this.catalog,
    required this.controller,
  });

  final CatalogModel catalog;
  final CatalogsController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Obx(() {
          final isLoading = controller.isAssigningCatalog.value;

          return Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 0,
              vertical: 6,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 12 : 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB300).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            FluentIcons.info_24_regular,
                            color: Color(0xFFF57C00),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMessage(context, true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : () => controller.assignCatalogToCommerce(catalog.id),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(FluentIcons.link_24_regular, size: 16),
                          label: Text(
                            isLoading ? 'Asignando...' : 'Agregar a este comercio',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PUColors.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: PUColors.primaryColor.withOpacity(0.5),
                            disabledForegroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(
                        FluentIcons.info_24_regular,
                        color: Color(0xFFF57C00),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMessage(context, false),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : () => controller.assignCatalogToCommerce(catalog.id),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(FluentIcons.link_24_regular, size: 16),
                        label: Text(
                          isLoading ? 'Asignando...' : 'Agregar a este comercio',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PUColors.primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: PUColors.primaryColor.withOpacity(0.5),
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
          );
        });
      },
    );
  }

  String get _catalogName {
    final name = catalog.name;
    if (name != null && name.isNotEmpty) return name;
    final desc = catalog.description;
    if (desc != null && desc.isNotEmpty) return desc;
    return 'Catálogo sin nombre';
  }

  Widget _buildMessage(BuildContext context, bool isMobile) {
    return RichText(
      text: TextSpan(
        style: PuTextStyle.description1.copyWith(
          color: const Color(0xFF5D4037),
          fontWeight: isMobile ? FontWeight.w600 : FontWeight.w500,
        ),
        children: [
          const TextSpan(text: 'El catálogo '),
          TextSpan(
            text: _catalogName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(
            text: ' no está asociado a ningún comercio. Haz clic en el botón para vincularlo a este negocio.',
          ),
        ],
      ),
    );
  }
}
