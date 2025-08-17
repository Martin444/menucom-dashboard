import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/utils/pu_colors.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:svg_flutter/svg.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? PUColors.bgItemMenuSelected : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: PUColors.primaryColor.withOpacity(0.3)) : null,
              ),
              child: Row(
                children: [
                  // Icono principal
                  Stack(
                    children: [
                      SvgPicture.asset(
                        config.icon,
                        colorFilter: ColorFilter.mode(
                          _getIconColor(isSelected, isComingSoon),
                          BlendMode.src,
                        ),
                      ),
                      // Badge si es necesario
                      if (showBadge && badgeText != null)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: PUColors.primaryColor,
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
                  const SizedBox(width: 10),

                  // Texto del label
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          config.label,
                          style: PuTextStyle.title3.copyWith(
                            color: _getTextColor(isSelected, isComingSoon),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: PUColors.bgItem,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Próximamente',
                              style: PuTextStyle.description1.copyWith(
                                fontSize: 9,
                                color: PUColors.iconColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Indicador de selección
                  if (isSelected)
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: PUColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
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
      return PUColors.iconColor.withOpacity(0.5);
    }
    return isSelected ? PUColors.primaryColor : PUColors.iconColor;
  }

  Color _getTextColor(bool isSelected, bool isComingSoon) {
    if (isComingSoon) {
      return PUColors.iconColor.withOpacity(0.5);
    }
    return isSelected ? PUColors.primaryColor : PUColors.iconColor;
  }
}
