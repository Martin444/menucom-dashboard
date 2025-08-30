import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

/// Widget reutilizable para mostrar una sección de tags/categorías con funcionalidad
/// de selección, edición y otras acciones.
///
/// Generic parameters:
/// - [T]: Tipo de los elementos en la lista (ej: MenuModel, WardrobeModel)
class CategoryTagsSection<T> extends StatelessWidget {
  const CategoryTagsSection({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.descriptionBuilder,
    required this.itemCountBuilder,
    required this.constrains,
    this.onEditSelected,
    this.onDeleteSelected,
    this.actionButtons = const [],
    this.icon = Icons.category,
    this.emptyMessage,
  });

  /// Título de la sección (ej: "Mis Menús", "Mis Guardarropas")
  final String title;

  /// Lista de elementos a mostrar
  final List<T> items;

  /// Elemento actualmente seleccionado
  final T selectedItem;

  /// Callback cuando se selecciona un elemento
  final ValueChanged<T> onItemSelected;

  /// Constructor para obtener la descripción de un elemento
  final String Function(T item) descriptionBuilder;

  /// Constructor para obtener el conteo de items de un elemento
  final int Function(T item) itemCountBuilder;

  /// Constrains del layout padre para responsividad
  final BoxConstraints constrains;

  /// Callback para editar el elemento seleccionado
  final VoidCallback? onEditSelected;

  /// Callback para eliminar el elemento seleccionado
  final VoidCallback? onDeleteSelected;

  /// Botones de acción adicionales para el header
  final List<Widget> actionButtons;

  /// Icono a mostrar en cada tag
  final IconData icon;

  /// Mensaje cuando no hay elementos (opcional)
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    // Debug: Verificar los items recibidos
    debugPrint('=== DEBUG CategoryTagsSection ===');
    debugPrint('Title: $title');
    debugPrint('Items length: ${items.length}');
    for (int i = 0; i < items.length; i++) {
      debugPrint('Item $i: ${descriptionBuilder(items[i])}');
    }
    debugPrint('Selected item: ${descriptionBuilder(selectedItem)}');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PUColors.bgItem,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PUColors.borderInputColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: PuTextStyle.title3.copyWith(
                  fontSize: constrains.maxWidth < 600 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Action buttons for selected item
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  if (onEditSelected != null) ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onEditSelected,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: PUColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            FluentIcons.edit_24_regular,
                            size: 16,
                            color: PUColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Delete button
                  if (onDeleteSelected != null) ...[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onDeleteSelected,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            FluentIcons.delete_24_regular,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Custom action buttons
                  ...actionButtons,
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items Tags Grid
          if (items.isNotEmpty)
            Wrap(
              spacing: constrains.maxWidth < 600 ? 6 : 8,
              runSpacing: constrains.maxWidth < 600 ? 6 : 8,
              children: items.map((item) {
                final isSelected = selectedItem == item;
                final isSmallScreen = constrains.maxWidth < 600;
                final itemCount = itemCountBuilder(item);

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onItemSelected(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? PUColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? PUColors.primaryColor : PUColors.borderInputColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: PUColors.primaryColor.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon
                          Icon(
                            icon,
                            size: isSmallScreen ? 14 : 16,
                            color: isSelected ? Colors.white : PUColors.iconColor,
                          ),
                          const SizedBox(width: 6),

                          // Item description
                          Flexible(
                            child: Text(
                              descriptionBuilder(item),
                              style: PuTextStyle.description1.copyWith(
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : PUColors.textColor3,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),

                          // Item count badge
                          if (itemCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected ? Colors.white.withOpacity(0.2) : PUColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$itemCount',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : PUColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            // Empty state
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  emptyMessage ?? 'No hay elementos disponibles',
                  style: PuTextStyle.description1.copyWith(
                    color: PUColors.textColor3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
