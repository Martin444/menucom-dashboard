// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pu_material/pu_material.dart';
// import '../controllers/business_selection_controller.dart';
// import '../widgets/business_type_card.dart';
// import '../../models/business_type.dart';

// /// Pantalla de selección de tipo de negocio - Responsiva para Web y Mobile
// class BusinessSelectionPage extends StatelessWidget {
//   const BusinessSelectionPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(BusinessSelectionController());
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWeb = screenWidth > 800;

//     return Scaffold(
//       backgroundColor: PUColors.primaryBackground,
//       body: SafeArea(
//         child: isWeb ? _buildWebLayout(controller, context) : _buildMobileLayout(controller, context),
//       ),
//     );
//   }

//   /// Layout optimizado para Web
//   Widget _buildWebLayout(BusinessSelectionController controller, BuildContext context) {
//     return Row(
//       children: [
//         // Panel izquierdo con información
//         Expanded(
//           flex: 2,
//           child: Container(
//             padding: const EdgeInsets.all(40),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   PUColors.primaryColor.withValues(alpha: 0.1),
//                   PUColors.secundaryBackground.withValues(alpha: 0.05),
//                 ],
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Título principal
//                 Text(
//                   '¡Comenzá tu emprendimiento!',
//                   style: PuTextStyle.title1.copyWith(
//                     fontSize: 32,
//                     fontWeight: FontWeight.w700,
//                     color: PUColors.textColor3,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Subtítulo
//                 Text(
//                   'Elegí el tipo de negocio que mejor se adapte a tu emprendimiento y accedé a herramientas especializadas.',
//                   style: PuTextStyle.title3.copyWith(
//                     fontSize: 18,
//                     height: 1.5,
//                     color: PUColors.textColor1,
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Beneficios
//                 ..._buildBenefitsList(),

//                 const Spacer(),

//                 // Botones de acción en la parte inferior
//                 _buildWebActionButtons(controller),
//               ],
//             ),
//           ),
//         ),

//         // Panel derecho con opciones
//         Expanded(
//           flex: 3,
//           child: Container(
//             padding: const EdgeInsets.all(40),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header del panel
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Tipos de negocio',
//                       style: PuTextStyle.title2.copyWith(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: controller.cancel,
//                       icon: Icon(
//                         Icons.close,
//                         color: PUColors.textColor1,
//                         size: 24,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Grid de opciones
//                 Expanded(
//                   child: _buildBusinessTypesGrid(controller, crossAxisCount: 2),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Layout optimizado para Mobile y Tablet
//   Widget _buildMobileLayout(BusinessSelectionController controller, BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;

//     return CustomScrollView(
//       slivers: [
//         // App Bar personalizado
//         SliverAppBar(
//           expandedHeight: isTablet ? 220 : 180,
//           floating: false,
//           pinned: true,
//           backgroundColor: PUColors.primaryBackground,
//           elevation: 0,
//           leading: IconButton(
//             onPressed: controller.cancel,
//             icon: Icon(
//               Icons.arrow_back_ios,
//               color: PUColors.textColor3,
//               size: 20,
//             ),
//           ),
//           flexibleSpace: FlexibleSpaceBar(
//             background: Container(
//               padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 60, 20, 20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     PUColors.primaryColor.withValues(alpha: 0.1),
//                     PUColors.secundaryBackground.withValues(alpha: 0.05),
//                   ],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '¡Comenzá tu emprendimiento!',
//                     style: PuTextStyle.title1.copyWith(
//                       fontSize: isTablet ? 28 : 24,
//                       fontWeight: FontWeight.w700,
//                       color: PUColors.textColor3,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Elegí el tipo de negocio que mejor se adapte a tu emprendimiento.',
//                     style: PuTextStyle.title3.copyWith(
//                       fontSize: isTablet ? 16 : 14,
//                       color: PUColors.textColor1,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         // Contenido principal
//         SliverPadding(
//           padding: const EdgeInsets.all(20),
//           sliver: SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Grid responsivo de opciones
//                 _buildBusinessTypesGrid(
//                   controller,
//                   crossAxisCount: isTablet ? 2 : 1,
//                 ),

//                 const SizedBox(height: 24),

//                 // Botones de acción
//                 _buildMobileActionButtons(controller),

//                 // Espacio adicional para evitar que el FAB tape el contenido
//                 const SizedBox(height: 80),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Grid de tipos de negocio adaptable
//   Widget _buildBusinessTypesGrid(BusinessSelectionController controller, {required int crossAxisCount}) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         childAspectRatio: crossAxisCount == 1 ? 3.5 : 1.2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: BusinessType.availableTypes.length,
//       itemBuilder: (context, index) {
//         final businessType = BusinessType.availableTypes[index];

//         return Obx(() {
//           final isSelected = controller.selectedBusinessType?.id == businessType.id;

//           return BusinessTypeCard(
//             businessType: businessType,
//             isSelected: isSelected,
//             onTap: () => controller.selectBusinessType(businessType),
//             isCompact: crossAxisCount > 1,
//           );
//         });
//       },
//     );
//   }

//   /// Lista de beneficios para el panel web
//   List<Widget> _buildBenefitsList() {
//     final benefits = [
//       'Herramientas especializadas para tu sector',
//       'Gestión simplificada de inventario y ventas',
//       'Reportes y análisis personalizados',
//       'Soporte técnico especializado',
//     ];

//     return benefits
//         .map((benefit) => Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: PUColors.primaryColor,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       benefit,
//                       style: PuTextStyle.title3.copyWith(
//                         fontSize: 16,
//                         color: PUColors.textColor3,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ))
//         .toList();
//   }

//   /// Botones de acción para Web
//   Widget _buildWebActionButtons(BusinessSelectionController controller) {
//     return Obx(() => Row(
//           children: [
//             Expanded(
//               child: ButtonSecundary(
//                 title: 'Cancelar',
//                 onPressed: controller.cancel,
//                 load: false,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: ButtonPrimary(
//                 title: 'Confirmar selección',
//                 onPressed: controller.selectedBusinessType != null ? controller.confirmSelection : null,
//                 load: controller.isLoading,
//               ),
//             ),
//           ],
//         ));
//   }

//   /// Botones de acción para Mobile
//   Widget _buildMobileActionButtons(BusinessSelectionController controller) {
//     return Obx(() => Column(
//           children: [
//             // Botón principal
//             SizedBox(
//               width: double.infinity,
//               child: ButtonPrimary(
//                 title: 'Confirmar selección',
//                 onPressed: controller.selectedBusinessType != null ? controller.confirmSelection : null,
//                 load: controller.isLoading,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // Botón secundario
//             SizedBox(
//               width: double.infinity,
//               child: ButtonSecundary(
//                 title: 'Cancelar',
//                 onPressed: controller.cancel,
//                 load: false,
//               ),
//             ),
//           ],
//         ));
//   }
// }
