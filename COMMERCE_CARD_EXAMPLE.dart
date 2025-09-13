/// Ejemplo de uso de CommerceCard con botón de visitar tienda
///
/// Este archivo muestra cómo usar la CommerceCard actualizada con la nueva funcionalidad
/// de "Visitar tienda" que incluye el parámetro storeUrl.

import 'package:flutter/material.dart';
import 'package:menu_dart_api/by_feature/menu/get_menu_bydinning/model/menu_model.dart';
import 'lib/features/home/presentation/views/customer/molecules/customer_molecules.dart';

class CommerceCardExample extends StatelessWidget {
  const CommerceCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo CommerceCard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ejemplo 1: Card con URL completa (https://)
            CommerceCard(
              name: 'Restaurante La Terraza',
              category: 'Restaurante Gourmet',
              rating: 4.8,
              distance: '1.2 km',
              imageUrl: 'https://example.com/restaurant-image.jpg',
              email: 'contacto@laterraza.com',
              phone: '+57 300 123 4567',
              isEmailVerified: true,
              memberSince: DateTime.now().subtract(const Duration(days: 365)),
              lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
              storeUrl: 'https://www.laterraza.com', // URL completa
              onTap: () {
                print('Tapped on Restaurante La Terraza');
              },
            ),

            const SizedBox(height: 16),

            // Ejemplo 2: Card con URL sin protocolo (se agregará https:// automáticamente)
            CommerceCard(
              name: 'Pizzería Mario',
              category: 'Pizzería Italiana',
              rating: 4.5,
              distance: '800 m',
              imageUrl: 'https://example.com/pizza-image.jpg',
              email: 'pedidos@pizzeriamario.co',
              phone: '+57 301 987 6543',
              isEmailVerified: true,
              memberSince: DateTime.now().subtract(const Duration(days: 120)),
              lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
              storeUrl: 'pizzeriamario.co', // URL sin protocolo
              onTap: () {
                print('Tapped on Pizzería Mario');
              },
            ),

            const SizedBox(height: 16),

            // Ejemplo 3: Card sin URL de tienda (no mostrará el botón)
            CommerceCard(
              name: 'Café Central',
              category: 'Cafetería',
              rating: 4.2,
              distance: '500 m',
              imageUrl: 'https://example.com/cafe-image.jpg',
              email: 'info@cafecentral.com',
              phone: '+57 302 456 7890',
              isEmailVerified: false,
              memberSince: DateTime.now().subtract(const Duration(days: 30)),
              lastActivity: DateTime.now().subtract(const Duration(days: 1)),
              // storeUrl: null, // Sin URL - no mostrará el botón
              onTap: () {
                print('Tapped on Café Central');
              },
            ),

            const SizedBox(height: 16),

            // Ejemplo 4: Card con menús y URL de tienda
            // CommerceCard(
            //   name: 'Burger House',
            //   category: 'Comida Rápida',
            //   rating: 4.6,
            //   distance: '1.5 km',
            //   imageUrl: 'https://example.com/burger-image.jpg',
            //   email: 'delivery@burgerhouse.com',
            //   phone: '+57 304 111 2222',
            //   isEmailVerified: true,
            //   memberSince: DateTime.now().subtract(const Duration(days: 200)),
            //   lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
            //   storeUrl: 'https://burgerhouse.com/menu',
            //   menus: _getExampleMenus(), // Menús de ejemplo
            //   onTap: () {
            //     print('Tapped on Burger House');
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  /// Genera menús de ejemplo para mostrar la funcionalidad completa
//   List<MenuModel> _getExampleMenus() {
//     return [
//       MenuModel(
//         id: 1,
//         description: 'Menú Principal',
//         items: [
//           // Aquí irían los items del menú
//           // Para el ejemplo, usamos una lista vacía o simulada
//         ],
//       ),
//       MenuModel(
//         id: 2,
//         description: 'Menú de Postres',
//         items: [
//           // Items de postres
//         ],
//       ),
//     ];
//   }
// }

  /// Casos de uso típicos para storeUrl:
  ///
  /// 1. URL del sitio web oficial del comercio:
  ///    storeUrl: 'https://www.mirestaurante.com'
  ///
  /// 2. Página específica de menú online:
  ///    storeUrl: 'https://www.mirestaurante.com/menu'
  ///
  /// 3. Perfil en plataforma de delivery:
  ///    storeUrl: 'https://rappi.com/restaurants/mi-restaurante'
  ///
  /// 4. Redes sociales del negocio:
  ///    storeUrl: 'https://instagram.com/mirestaurante'
  ///
  /// 5. WhatsApp Business:
  ///    storeUrl: 'https://wa.me/573001234567'
  ///
  /// 6. URL sin protocolo (se agregará https:// automáticamente):
  ///    storeUrl: 'mirestaurante.com'
  ///
  /// 7. URL vacía o null (no mostrará el botón):
  ///    storeUrl: null
  ///    storeUrl: ''
  ///    storeUrl: '   ' // Solo espacios en blanco

  /// Notas importantes:
  ///
  /// - El botón solo aparece si storeUrl no es null y no está vacío
  /// - Si la URL no tiene protocolo, se agrega 'https://' automáticamente
  /// - La URL se abre en el navegador externo del dispositivo
  /// - Se incluye manejo de errores para URLs inválidas
  /// - El botón usa el ícono FluentIcons.globe_24_regular
  /// - El estilo del botón es consistente con el tema de PUColors
}
