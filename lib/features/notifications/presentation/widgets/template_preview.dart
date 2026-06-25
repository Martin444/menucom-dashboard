import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/notifications/models/paginated_templates_response.dart';
import 'package:pu_material/pu_material.dart';
import '../../getx/notifications_controller.dart';

class TemplatePreview extends StatelessWidget {
  final NotificationTemplateListItem template;
  final VoidCallback? onEdit;

  const TemplatePreview({
    super.key,
    required this.template,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Card(
      elevation: 0,
      color: PUColors.bgItem,
      shape: RoundedRectangleBorder(
        borderRadius: PUBorderRadius.lg,
        side: const BorderSide(color: PUColors.borderInputColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PUTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Template seleccionado',
                  style: PuTextStyle.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PUColors.textColorRich,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    child: Text(
                      'Cambiar',
                      style: PuTextStyle.bodySmall.copyWith(
                        color: PUColors.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: PUTokens.xs),
            Text(
              template.name,
              style: PuTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: PUColors.textColorRich,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              template.title,
              style: PuTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: PUColors.textColorRich,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              template.body,
              style: PuTextStyle.bodySmall,
            ),
            if (template.placeholderCount > 0) ...[
              const SizedBox(height: PUTokens.sm),
              Text(
                'Placeholders',
                style: PuTextStyle.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PUColors.textColorRich,
                ),
              ),
              const SizedBox(height: PUTokens.xs),
              Obx(() {
                return Column(
                  children: controller.placeholders.keys.map((key) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: PUTokens.xs),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: '{{$key}}',
                          labelStyle: PuTextStyle.description1.copyWith(
                            color: PUColors.textColorMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: PUColors.bgInput,
                          border: OutlineInputBorder(
                            borderRadius: PUBorderRadius.md,
                            borderSide: const BorderSide(
                                color: PUColors.borderInputColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: PUBorderRadius.md,
                            borderSide: const BorderSide(
                                color: PUColors.borderInputColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: PUBorderRadius.md,
                            borderSide: const BorderSide(
                                color: PUColors.primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        style: PuTextStyle.hintTextStyle,
                        onChanged: (value) {
                          controller.updatePlaceholder(key, value);
                        },
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
