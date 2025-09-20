/// Widget optimizado para mobile, más legible y visual
///
library;

import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import '../../models/business_type.dart';

class BusinessTypeCardMobile extends StatelessWidget {
  final BusinessType businessType;
  final bool isSelected;
  final VoidCallback onTap;

  const BusinessTypeCardMobile({
    super.key,
    required this.businessType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _getColorFromHex(businessType.colorHex).withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? _getColorFromHex(businessType.colorHex).withValues(alpha: 0.35)
                : PUColors.borderInputColor,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _getColorFromHex(businessType.colorHex).withValues(alpha: 0.18)
                  : Colors.grey.withValues(alpha: 0.09),
              blurRadius: isSelected ? 16 : 6,
              offset: const Offset(0, 6),
              spreadRadius: isSelected ? 3 : 0,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getIconForBusinessType(businessType.id),
                        color: _getColorFromHex(businessType.colorHex),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        businessType.title,
                        style: PuTextStyle.title1.copyWith(
                          color: isSelected ? _getColorFromHex(businessType.colorHex) : PUColors.textColor3,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _getColorFromHex(businessType.colorHex),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Make description flexible so it can shrink if needed
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    businessType.description,
                    style: PuTextStyle.title2.copyWith(
                      color: PUColors.textColor1,
                      height: 1.35,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 8),

                // Features as a horizontal scrollable row with constrained height
                SizedBox(
                  height: 36,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: businessType.features.take(4).map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.28),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              feature,
                              style: PuTextStyle.title3.copyWith(
                                color: _getColorFromHex(businessType.colorHex),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Convierte color hex a Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  /// Obtiene el icono apropiado para cada tipo de negocio
  IconData _getIconForBusinessType(String businessId) {
    switch (businessId) {
      case 'food_store':
        return Icons.restaurant;
      case 'clothes':
        return Icons.checkroom;
      case 'general_commerce':
        return Icons.store;
      case 'distributor':
        return Icons.local_shipping;
      case 'service':
        return Icons.build;
      default:
        return Icons.business;
    }
  }
}

/// Widget que representa una tarjeta de tipo de negocio seleccionable
class BusinessTypeCard extends StatelessWidget {
  final BusinessType businessType;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const BusinessTypeCard({
    super.key,
    required this.businessType,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: isCompact ? const EdgeInsets.all(6) : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? _getColorFromHex(businessType.colorHex).withValues(alpha: 0.05) // Más suave
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _getColorFromHex(businessType.colorHex).withValues(alpha: 0.3) // Más suave
                : PUColors.borderInputColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _getColorFromHex(businessType.colorHex).withValues(alpha: 0.15) // Más suave
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 4),
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
      ),
    );
  }

  /// Layout completo para mobile
  Widget _buildFullLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y título
          Row(
            children: [
              // Icono
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getIconForBusinessType(businessType.id),
                  color: _getColorFromHex(businessType.colorHex),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Título y check
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        businessType.title,
                        style: PuTextStyle.title1.copyWith(
                          color: isSelected ? _getColorFromHex(businessType.colorHex) : PUColors.textColor3,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 21,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _getColorFromHex(businessType.colorHex),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Descripción
          Text(
            businessType.description,
            style: PuTextStyle.title2.copyWith(
              color: PUColors.textColor1,
              height: 1.35,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),

          // Features
          _buildFeatures(showAll: isSelected),
        ],
      ),
    );
  }

  /// Layout compacto para web/grid
  Widget _buildCompactLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono principal
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getIconForBusinessType(businessType.id),
            color: _getColorFromHex(businessType.colorHex),
            size: 16,
          ),
        ),
        const SizedBox(height: 5),

        // Título
        Text(
          businessType.title,
          style: PuTextStyle.title3.copyWith(
            color: isSelected ? _getColorFromHex(businessType.colorHex) : PUColors.textColor3,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),

        // Descripción abreviada
        Text(
          businessType.description,
          style: PuTextStyle.title3.copyWith(
            color: PUColors.textColor1,
            fontSize: 8,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const Spacer(),

        // Indicador de selección
        if (isSelected)
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _getColorFromHex(businessType.colorHex),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 13,
            ),
          )
        else
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: PUColors.borderInputColor,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }

  /// Construye las features con opción de mostrar todas
  Widget _buildFeatures({bool showAll = false}) {
    final featuresToShow = showAll ? businessType.features : businessType.features.take(2).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: featuresToShow.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            feature,
            style: PuTextStyle.title3.copyWith(
              color: _getColorFromHex(businessType.colorHex),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Convierte color hex a Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  /// Obtiene el icono apropiado para cada tipo de negocio
  IconData _getIconForBusinessType(String businessId) {
    switch (businessId) {
      case 'food_store':
        return Icons.restaurant;
      case 'clothes':
        return Icons.checkroom;
      case 'general_commerce':
        return Icons.store;
      case 'distributor':
        return Icons.local_shipping;
      case 'service':
        return Icons.build;
      default:
        return Icons.business;
    }
  }
}
