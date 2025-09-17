import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import '../controllers/business_selection_controller.dart';
import '../widgets/business_type_card.dart';
import '../../models/business_type.dart';

/// Pantalla de selección de tipo de negocio - Responsiva para Web y Mobile
class BusinessSelectionPage extends StatelessWidget {
  const BusinessSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessSelectionController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: SafeArea(
        child: isWeb ? _buildWebLayout(controller, context) : _buildMobileLayout(controller, context),
      ),
    );
  }

  /// Layout optimizado para Web
  Widget _buildWebLayout(BusinessSelectionController controller, BuildContext context) {
    return Row(
      children: [
        // Panel izquierdo con información
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PUColors.primaryColor.withValues(alpha: 0.1),
                  PUColors.secundaryBackground.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título principal
                Text(
                  '¡Comenzá tu emprendimiento!',
                  style: PuTextStyle.title1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: PUColors.textColor3,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtítulo
                Text(
                  'Elegí el tipo de negocio que mejor se adapte a tu emprendimiento y accedé a herramientas especializadas.',
                  style: PuTextStyle.title3.copyWith(
                    fontSize: 18,
                    height: 1.5,
                    color: PUColors.textColor1,
                  ),
                ),
                const SizedBox(height: 32),

                // Beneficios
                ..._buildBenefitsList(),

                const Spacer(),

                // Botones de acción en la parte inferior
                _buildWebActionButtons(controller),
              ],
            ),
          ),
        ),

        // Panel derecho con opciones
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del panel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tipos de negocio',
                      style: PuTextStyle.title2.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.cancel,
                      icon: Icon(
                        Icons.close,
                        color: PUColors.textColor1,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Grid de opciones
                Expanded(
                  child: _buildWebBusinessTypesGrid(controller),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Layout optimizado para Mobile y Tablet
  Widget _buildMobileLayout(BusinessSelectionController controller, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return CustomScrollView(
      slivers: [
        // App Bar personalizado
        SliverAppBar(
          expandedHeight: isTablet ? 240 : 360,
          floating: false,
          pinned: true,
          backgroundColor: PUColors.primaryBackground,
          elevation: 0,
          leading: IconButton(
            onPressed: controller.cancel,
            icon: Icon(
              Icons.arrow_back_ios,
              color: PUColors.textColor3,
              size: 20,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                // Fondo con gradiente más intenso y decorativo
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        PUColors.primaryColor.withValues(alpha: 0.22),
                        PUColors.primaryColor.withValues(alpha: 0.09),
                        PUColors.secundaryBackground.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
                // Icono grande decorativo arriba del título
                Positioned(
                  top: MediaQuery.of(context).padding.top + 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: isTablet ? 70 : 90,
                      height: isTablet ? 70 : 90,
                      decoration: BoxDecoration(
                        color: PUColors.primaryColor.withValues(alpha: 0.13),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: PUColors.primaryColor.withValues(alpha: 0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Hero(
                        tag: 'dashLogo',
                        child: Image.asset(
                          PUImages.dashLogo,
                          height: 90,
                        ),
                      ),
                    ),
                  ),
                ),
                // Título y subtítulo con sombra
                Positioned(
                  top: MediaQuery.of(context).padding.top + (isTablet ? 100 : 130),
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Comenzá tu emprendimiento!',
                        style: PuTextStyle.title1.copyWith(
                          fontSize: isTablet ? 32 : 28,
                          fontWeight: FontWeight.w800,
                          color: PUColors.textColor3,
                          shadows: [
                            Shadow(
                              color: PUColors.primaryColor.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Elegí el tipo de negocio que mejor se adapte a tu emprendimiento.',
                        style: PuTextStyle.title3.copyWith(
                          fontSize: isTablet ? 17 : 15,
                          color: PUColors.textColor1,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: PUColors.primaryColor.withValues(alpha: 0.10),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Detalle decorativo inferior (borde curvo)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: PUColors.primaryBackground,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PUColors.primaryColor.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenido principal
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Grid responsivo de opciones
                _buildBusinessTypesGrid(controller, context, crossAxisCount: isTablet ? 1 : 1),

                const SizedBox(height: 24),

                // Botones de acción
                _buildMobileActionButtons(controller),

                // Espacio adicional para evitar que el FAB tape el contenido
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Grid de tipos de negocio adaptable
  Widget _buildBusinessTypesGrid(BusinessSelectionController controller, BuildContext context,
      {required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio:
            crossAxisCount == 1 ? (MediaQuery.of(context).size.width > 600 ? 3.2 : 1.7) : 0.9, // Ajuste de proporción
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: BusinessType.availableTypes.length,
      itemBuilder: (context, index) {
        final businessType = BusinessType.availableTypes[index];

        return Obx(() {
          final isSelected = controller.selectedBusinessType?.id == businessType.id;

          // Use mobile-optimized card when grid is single-column (mobile)
          if (crossAxisCount == 1) {
            return BusinessTypeCardMobile(
              businessType: businessType,
              isSelected: isSelected,
              onTap: () => controller.selectBusinessType(businessType),
            );
          }

          return BusinessTypeCard(
            businessType: businessType,
            isSelected: isSelected,
            onTap: () => controller.selectBusinessType(businessType),
            isCompact: crossAxisCount > 1,
          );
        });
      },
    );
  }

  /// Grid específico para Web con scroll habilitado
  Widget _buildWebBusinessTypesGrid(BusinessSelectionController controller) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3, // Proporción más equilibrada para web
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: BusinessType.availableTypes.length,
      itemBuilder: (context, index) {
        final businessType = BusinessType.availableTypes[index];

        return Obx(() {
          final isSelected = controller.selectedBusinessType?.id == businessType.id;

          return BusinessTypeCard(
            businessType: businessType,
            isSelected: isSelected,
            onTap: () => controller.selectBusinessType(businessType),
            isCompact: true, // Siempre compacto para web
          );
        });
      },
    );
  }

  /// Lista de beneficios para el panel web
  List<Widget> _buildBenefitsList() {
    final benefits = [
      'Herramientas especializadas para tu sector',
      'Gestión simplificada de inventario y ventas',
      'Reportes y análisis personalizados',
      'Soporte técnico especializado',
    ];

    return benefits
        .map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: PUColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: PuTextStyle.title3.copyWith(
                        fontSize: 16,
                        color: PUColors.textColor3,
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  /// Botones de acción para Web
  Widget _buildWebActionButtons(BusinessSelectionController controller) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: ButtonSecundary(
                title: 'Cancelar',
                onPressed: controller.cancel,
                load: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ButtonPrimary(
                title: 'Confirmar selección',
                onPressed: controller.selectedBusinessType != null ? controller.confirmSelection : null,
                load: controller.isLoading,
              ),
            ),
          ],
        ));
  }

  /// Botones de acción para Mobile
  Widget _buildMobileActionButtons(BusinessSelectionController controller) {
    return Obx(() => Column(
          children: [
            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ButtonPrimary(
                title: 'Confirmar selección',
                onPressed: controller.selectedBusinessType != null ? controller.confirmSelection : null,
                load: controller.isLoading,
              ),
            ),
            const SizedBox(height: 12),

            // Botón secundario
            SizedBox(
              width: double.infinity,
              child: ButtonSecundary(
                title: 'Cancelar',
                onPressed: controller.cancel,
                load: false,
              ),
            ),
          ],
        ));
  }
}
