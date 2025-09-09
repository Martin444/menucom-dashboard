// /// Ejemplo de uso del nuevo sistema de navegación escalable
// /// 
// /// Este archivo demuestra cómo usar las nuevas características implementadas

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// // Importaciones del nuevo sistema
// import '../lib/core/navigation/menu_navigation_controller.dart';
// import '../lib/core/navigation/menu_navigation_items.dart';
// import '../lib/core/mixins/navigation_state_mixin.dart';
// import '../lib/widgets/enhanced_menu_draw_item.dart';

// /// Ejemplo 1: Cómo agregar un nuevo item al menú
// void agregarNuevoItemAlMenu() {
//   /*
//   1. Agregar el nuevo item al enum en menu_navigation_items.dart:
  
//   enum MenuNavigationItem {
//     home,
//     orders,
//     sales,
//     clients,
//     suppliers,
//     profile,
//     logout,
//     inventory, // ← Nuevo item
//   }
  
//   2. Agregar su configuración en el mismo archivo:
  
//   case MenuNavigationItem.inventory:
//     return MenuItemConfig(
//       icon: PUIcons.iconInventory,
//       label: 'Inventario',
//       route: PURoutes.INVENTORY,
//       isNavigationRoute: true,
//     );
    
//   3. Actualizar la función getItemsByRole si es necesario:
  
//   case 'dinning':
//     return [home, orders, sales, inventory, ...actionItems];
//   */
// }

// /// Ejemplo 2: Controlador con navegación sincronizada
// class EjemploController extends GetxController with NavigationStateMixin {
  
//   @override
//   void onReady() {
//     super.onReady();
//     // Sincronizar automáticamente el estado de navegación
//     syncNavigationState();
//   }
  
//   void navegarAInventario() {
//     // El controlador de navegación maneja automáticamente la lógica
//     final navController = Get.find<MenuNavigationController>();
//     navController.navigateToItem(MenuNavigationItem.home);
//   }
// }

// /// Ejemplo 3: Widget personalizado que usa el nuevo sistema
// class EjemploWidget extends StatelessWidget {
//   const EjemploWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MenuNavigationController>(
//       builder: (navController) {
//         return Column(
//           children: [
//             // Mostrar items según el rol del usuario
//             ...navController.getMenuItems().map(
//               (item) => EnhancedMenuDrawItem(
//                 item: item,
//                 showBadge: item == MenuNavigationItem.orders,
//                 badgeText: '3', // Ejemplo: 3 órdenes pendientes
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// /// Ejemplo 4: Navegación programática
// class EjemploNavegacion {
//   void ejemploDeNavegacion() {
//     final navController = Get.find<MenuNavigationController>();
    
//     // Navegar a una página específica
//     navController.navigateToItem(MenuNavigationItem.orders);
    
//     // Verificar si un item está seleccionado
//     if (navController.isItemSelected(MenuNavigationItem.home)) {
//       debugPrint('Estamos en la página de inicio');
//     }
    
//     // Obtener items disponibles para el usuario actual
//     final availableItems = navController.getMenuItems();
//     debugPrint('Items disponibles: ${availableItems.length}');
//   }
// }

// /// Ejemplo 5: Manejo de rutas dinámicas
// void ejemploRutasDinamicas() {
//   /*
//   El sistema maneja automáticamente rutas como:
//   - /perfil/:idUsuario → Se reemplaza automáticamente con el nombre del usuario
//   - Rutas condicionales según permisos
//   - Parámetros dinámicos según el contexto
//   */
// }

// /// Ejemplo 6: Agregar badges dinámicos
// class Ejemplo_BadgesDinamicos extends StatelessWidget {
//   const Ejemplo_BadgesDinamicos({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return EnhancedMenuDrawItem(
//       item: MenuNavigationItem.orders,
//       showBadge: true,
//       badgeText: '5', // Número de órdenes pendientes
//       onCustomAction: () {
//         // Acción personalizada cuando se hace clic
//         Get.snackbar('Info', 'Tienes 5 órdenes pendientes');
//       },
//     );
//   }
// }

// /// Ejemplo 7: Funcionalidad "próximamente"
// void ejemploProximamente() {
//   /*
//   Para marcar una funcionalidad como "próximamente":
  
//   case MenuNavigationItem.sales:
//     return MenuItemConfig(
//       icon: PUIcons.iconSalesMenu,
//       label: 'Ventas',
//       route: null,
//       isNavigationRoute: false,
//       isComingSoon: true, // ← Esto muestra el badge "Próximamente"
//     );
//   */
// }

// /// Ejemplo 8: Testing del nuevo sistema
// void ejemploTesting() {
//   /*
//   test('MenuNavigationController debería navegar correctamente', () {
//     // Arrange
//     final controller = MenuNavigationController();
    
//     // Act
//     controller.navigateToItem(MenuNavigationItem.orders);
    
//     // Assert
//     expect(controller.isItemSelected(MenuNavigationItem.orders), true);
//     expect(Get.currentRoute, PURoutes.ORDERS_PAGES);
//   });
//   */
// }

// /// Resumen de beneficios:
// /// 
// /// ✅ Código más organizado y mantenible
// /// ✅ Fácil agregar nuevos items al menú
// /// ✅ Navegación automática basada en rutas
// /// ✅ Soporte para roles y permisos
// /// ✅ Estados visuales mejorados
// /// ✅ Badges y notificaciones
// /// ✅ Funcionalidades "próximamente"
// /// ✅ Sincronización automática de estado
// /// ✅ Testeable y escalable
