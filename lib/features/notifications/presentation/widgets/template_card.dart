import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/notifications/models/paginated_templates_response.dart';
import 'package:pu_material/pu_material.dart';

class TemplateCard extends StatelessWidget {
  final NotificationTemplateListItem template;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
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
          children: [
            Row(
              children: [
                const Icon(
                  FluentIcons.mail_alert_24_regular,
                  size: 20,
                  color: PUColors.textColorMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: PuTextStyle.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: PUColors.textColorRich,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: template.isActive
                        ? PUColors.successColor.withValues(alpha: 0.1)
                        : PUColors.errorColor.withValues(alpha: 0.1),
                    borderRadius: PUBorderRadius.full,
                  ),
                  child: Text(
                    template.isActive ? 'Activo' : 'Inactivo',
                    style: PuTextStyle.bodySmall.copyWith(
                      fontSize: PUTokens.fontXs,
                      fontWeight: FontWeight.w600,
                      color: template.isActive
                          ? PUColors.successColor
                          : PUColors.errorColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PUTokens.xs),
            Text(
              template.title,
              style: PuTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: PUColors.textColorRich,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              template.body,
              style: PuTextStyle.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (template.deepLink != null || template.imageUrl != null) ...[
              const SizedBox(height: PUTokens.xs),
              Wrap(
                spacing: 8,
                children: [
                  if (template.deepLink != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.link_24_regular,
                            size: 14, color: PUColors.textColorLight),
                        const SizedBox(width: 4),
                        Text(
                          'Deep link',
                          style: PuTextStyle.bodySmall.copyWith(
                            fontSize: PUTokens.fontXs,
                          ),
                        ),
                      ],
                    ),
                  if (template.imageUrl != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.image_24_regular,
                            size: 14, color: PUColors.textColorLight),
                        const SizedBox(width: 4),
                        Text(
                          'Imagen',
                          style: PuTextStyle.bodySmall.copyWith(
                            fontSize: PUTokens.fontXs,
                          ),
                        ),
                      ],
                    ),
                  if (template.placeholderCount > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.braces_24_regular,
                            size: 14, color: PUColors.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          '${template.placeholderCount} placeholders',
                          style: PuTextStyle.bodySmall.copyWith(
                            fontSize: PUTokens.fontXs,
                            color: PUColors.accentColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            const SizedBox(height: PUTokens.sm),
            const Divider(height: 1, color: PUColors.borderInputColor),
            const SizedBox(height: PUTokens.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(FluentIcons.edit_24_regular,
                      size: 16, color: PUColors.accentColor),
                  label: Text(
                    'Editar',
                    style: PuTextStyle.bodySmall.copyWith(
                      color: PUColors.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    FluentIcons.delete_24_regular,
                    size: 16,
                    color: PUColors.errorColor,
                  ),
                  label: Text(
                    'Desactivar',
                    style: PuTextStyle.bodySmall.copyWith(
                      color: PUColors.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
