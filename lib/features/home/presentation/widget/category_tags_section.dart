import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

/// Widget de transición que usa el nuevo CategorySectionOrganism de pu_material
///
/// Esta es una capa de compatibilidad que mantiene la API existente mientras
/// migra al nuevo sistema de componentes reutilizables.
///
/// @deprecated Use CategorySectionOrganism directly from pu_material
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
    // Usar el nuevo CategorySectionOrganism de pu_material
    return CategorySectionOrganism<T>(
      title: title,
      items: items,
      selectedItem: selectedItem,
      onItemSelected: onItemSelected,
      labelBuilder: descriptionBuilder,
      itemCountBuilder: itemCountBuilder,
      iconBuilder: (_) => icon,
      onEditSelected: onEditSelected,
      onDeleteSelected: onDeleteSelected,
      headerActions: actionButtons,
      emptyMessage: emptyMessage ?? 'No hay elementos disponibles',
      constrains: constrains,
      showAsGrid: true,
      maxTagsToShow: 15,
    );
  }
}
