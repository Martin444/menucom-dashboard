import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import '../../getx/notifications_controller.dart';
import '../widgets/template_card.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Column(
      children: [
        _buildHeader(context, controller),
        const Divider(height: 1, color: PUColors.borderInputColor),
        Expanded(
          child: _buildList(controller),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, NotificationsController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(PUTokens.lg, PUTokens.md, PUTokens.lg, PUTokens.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchTemplates(value),
              decoration: InputDecoration(
                hintText: 'Buscar templates...',
                hintStyle: PuTextStyle.hintTextStyle,
                prefixIcon:
                    const Icon(FluentIcons.search_24_regular, size: 20),
                prefixIconColor: PUColors.iconColor,
                filled: true,
                fillColor: PUColors.bgInput,
                border: OutlineInputBorder(
                  borderRadius: PUBorderRadius.md,
                  borderSide: const BorderSide(color: PUColors.borderInputColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: PUBorderRadius.md,
                  borderSide: const BorderSide(color: PUColors.borderInputColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: PUBorderRadius.md,
                  borderSide: const BorderSide(color: PUColors.primaryColor),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              style: PuTextStyle.hintTextStyle.copyWith(fontSize: 13),
            ),
          ),
          const SizedBox(width: PUTokens.sm),
          Obx(() {
            final isActive = controller.templatesFilterActive.value;
            return PopupMenuButton<bool?>(
              icon: Icon(
                FluentIcons.filter_24_regular,
                size: 20,
                color: isActive != null ? PUColors.accentColor : PUColors.textColorLight,
              ),
              tooltip: 'Filtrar',
              onSelected: (value) => controller.filterByActive(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: null, child: Text('Todos')),
                const PopupMenuItem(
                    value: true, child: Text('Activos')),
                const PopupMenuItem(
                    value: false, child: Text('Inactivos')),
              ],
            );
          }),
          const SizedBox(width: PUTokens.sm),
          ButtonPrimary(
            title: 'Nuevo',
            icon: FluentIcons.add_24_regular,
            load: false,
            onPressed: () {
              Get.toNamed(PURoutes.ADMIN_NOTIFICATIONS_TEMPLATE_CREATE)
                  ?.then((_) => controller.loadTemplates(refresh: true));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(NotificationsController controller) {
    return Obx(() {
      if (controller.isTemplatesLoading.value &&
          controller.templates.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.templatesError.value != null &&
          controller.templates.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.templatesError.value!,
                  style: const TextStyle(color: PUColors.errorColor)),
              const SizedBox(height: PUTokens.sm),
              ButtonPrimary(
                title: 'Reintentar',
                load: false,
                onPressed: () => controller.loadTemplates(refresh: true),
              ),
            ],
          ),
        );
      }

      if (controller.templates.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.document_24_regular,
                  size: 48, color: PUColors.textColorLight),
              const SizedBox(height: PUTokens.md),
              Text(
                'No hay templates de notificación',
                style: PuTextStyle.title3.copyWith(
                  color: PUColors.textColorMuted,
                  fontSize: PUTokens.fontMd,
                ),
              ),
              const SizedBox(height: PUTokens.xs),
              Text(
                'Creá tu primer template para empezar a enviar notificaciones push',
                style: PuTextStyle.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: PUTokens.xl),
              SizedBox(
                width: 260,
                child: ButtonPrimary(
                  title: 'Crear template',
                  icon: FluentIcons.add_24_regular,
                  load: false,
                  onPressed: () {
                    Get.toNamed(PURoutes.ADMIN_NOTIFICATIONS_TEMPLATE_CREATE)
                        ?.then((_) => controller.loadTemplates(refresh: true));
                  },
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadTemplates(refresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: PUTokens.lg, vertical: PUTokens.sm),
                itemCount: controller.templates.length,
                itemBuilder: (context, index) {
                  final template = controller.templates[index];
                  return TemplateCard(
                    template: template,
                    onTap: () {},
                    onEdit: () {
                      Get.toNamed(
                            PURoutes.ADMIN_NOTIFICATIONS_TEMPLATE_CREATE,
                            arguments: template.id,
                          )
                          ?.then((_) =>
                              controller.loadTemplates(refresh: true));
                    },
                    onDelete: () =>
                        controller.deleteTemplate(template.id, template.name),
                  );
                },
              ),
            ),
          ),
          Obx(() {
            if (controller.isTemplatesLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(PUTokens.sm),
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.templates.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: PUTokens.lg, vertical: PUTokens.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: controller.templatesPage.value > 1
                          ? () {
                              controller.templatesPage.value--;
                              controller.loadTemplates(refresh: true);
                            }
                          : null,
                      child: Text(
                        'Anterior',
                        style: PuTextStyle.bodySmall.copyWith(
                          color: controller.templatesPage.value > 1
                              ? PUColors.accentColor
                              : PUColors.textColorLight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: PUTokens.md),
                      child: Obx(() => Text(
                            'Pág. ${controller.templatesPage.value} de ${controller.templatesTotalPages}'
                                ' (${controller.templatesTotal} templates)',
                            style: PuTextStyle.bodySmall,
                          )),
                    ),
                    TextButton(
                      onPressed: controller.templatesHasMore.value
                          ? () => controller.loadMoreTemplates()
                          : null,
                      child: Text(
                        'Siguiente',
                        style: PuTextStyle.bodySmall.copyWith(
                          color: controller.templatesHasMore.value
                              ? PUColors.accentColor
                              : PUColors.textColorLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      );
    });
  }
}
