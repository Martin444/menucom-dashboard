import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import '../../models/business_type.dart';

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
        margin: isCompact ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: isCompact ? const EdgeInsets.all(16) : const EdgeInsets.all(20),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con icono y título
        Row(
          children: [
            // Icono
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForBusinessType(businessType.id),
                color: _getColorFromHex(businessType.colorHex),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
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
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
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
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Descripción
        Text(
          businessType.description,
          style: PuTextStyle.title3.copyWith(
            color: PUColors.textColor1,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Features
        _buildFeatures(showAll: isSelected),
      ],
    );
  }

  /// Layout compacto para web/grid
  Widget _buildCompactLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono principal
        Container(
          width: 55, // Aumentado de 50 a 55
          height: 55, // Aumentado de 50 a 55
          decoration: BoxDecoration(
            color: _getColorFromHex(businessType.colorHex).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14), // Ajustado proporcionalmente
          ),
          child: Icon(
            _getIconForBusinessType(businessType.id),
            color: _getColorFromHex(businessType.colorHex),
            size: 30, // Aumentado de 28 a 30
          ),
        ),
        const SizedBox(height: 10), // Aumentado de 8 a 10

        // Título
        Text(
          businessType.title,
          style: PuTextStyle.title2.copyWith(
            color: isSelected ? _getColorFromHex(businessType.colorHex) : PUColors.textColor3,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 16, // Aumentado de 14 a 16
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8), // Aumentado el espaciado

        // Descripción abreviada
        Text(
          businessType.description,
          style: PuTextStyle.title3.copyWith(
            color: PUColors.textColor1,
            fontSize: 13, // Aumentado de 11 a 13
            height: 1.3, // Aumentado para mejor legibilidad
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const Spacer(),

        // Indicador de selección
        if (isSelected)
          Container(
            width: 28, // Aumentado de 24 a 28
            height: 28, // Aumentado de 24 a 28
            decoration: BoxDecoration(
              color: _getColorFromHex(businessType.colorHex),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 18, // Aumentado de 16 a 18
            ),
          )
        else
          Container(
            width: 28, // Aumentado de 24 a 28
            height: 28, // Aumentado de 24 a 28
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
