import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import '../../core/navigation/menu_navigation_items.dart';
import '../../core/navigation/menu_navigation_controller.dart';

/// Widget mejorado para items del menú lateral con mejor gestión de estado
class EnhancedMenuDrawItem extends StatelessWidget {
  final MenuNavigationItem item;
  final bool showBadge;
  final String? badgeText;
  final VoidCallback? onCustomAction;

  const EnhancedMenuDrawItem({
    super.key,
    required this.item,
    this.showBadge = false,
    this.badgeText,
    this.onCustomAction,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuNavigationController>(
      builder: (controller) {
        final config = item.config;
        final isSelected = controller.isItemSelected(item);
        final isComingSoon = config.isComingSoon;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (onCustomAction != null) {
                onCustomAction!();
              } else {
                controller.navigateToItem(item);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? PUColors.bgItemMenuSelected : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Indicador de selección (Izquierda)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 4,
                    height: isSelected ? 20 : 0,
                    decoration: BoxDecoration(
                      color: PUColors.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: isSelected ? 12 : 0),

                  // Icono principal
                  Stack(
                    children: [
                      Icon(
                        config.icon,
                        color: _getIconColor(isSelected, isComingSoon),
                        size: 22,
                      ),
                      // Badge si es necesario
                      if (showBadge && badgeText != null)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: PUColors.accentColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              badgeText!,
                              style: PuTextStyle.description1.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Texto del label
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            config.label,
                            style: PuTextStyle.title3.copyWith(
                              color: _getTextColor(isSelected, isComingSoon),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: PUColors.bgItemMenuSelected,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Próximamente',
                              style: PuTextStyle.description1.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: PUColors.textColorMuted.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getIconColor(bool isSelected, bool isComingSoon) {
    if (isComingSoon) {
      return PUColors.iconColor.withValues(alpha: 0.5);
    }
    return isSelected ? PUColors.primaryColor : PUColors.iconColor;
  }

  Color _getTextColor(bool isSelected, bool isComingSoon) {
    if (isComingSoon) {
      return PUColors.iconColor.withValues(alpha: 0.5);
    }
    return isSelected ? PUColors.primaryColor : PUColors.iconColor;
  }
}
