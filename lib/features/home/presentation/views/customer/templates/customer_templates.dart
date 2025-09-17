import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import '../organisms/customer_organisms.dart';
import '../molecules/customer_molecules.dart';
import '../utils/responsive_breakpoints.dart';

/// TEMPLATES - Layouts y estructuras de página

/// Template: Layout móvil para customer
class CustomerMobileTemplate extends StatelessWidget {
  const CustomerMobileTemplate({
    super.key,
    required this.userName,
    required this.commercesList,
    required this.isLoadingCommerces,
    required this.accessTokenHashed,
    this.onCommerceSelected,
  });

  final String userName;
  final String accessTokenHashed;
  final List<UserByRoleModel> commercesList;
  final bool isLoadingCommerces;
  final void Function(UserByRoleModel)? onCommerceSelected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = ResponsiveBreakpoints.getResponsivePadding(screenWidth, basePadding: 16);
    final responsiveSpacing = ResponsiveBreakpoints.getResponsiveSpacing(screenWidth, baseSpacing: 24);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: responsivePadding,
        vertical: responsivePadding * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerWelcomeHeader(
            userName: userName,
            isMobile: true,
          ),
          SizedBox(height: responsiveSpacing),
          CustomerFeaturedCommerces(
            isMobile: true,
            commercesList: commercesList,
            isLoading: isLoadingCommerces,
            onCommerceSelected: onCommerceSelected,
            accessTokenHashed: accessTokenHashed,
          ),
          SizedBox(height: responsiveSpacing),
          const CustomerServiceInfo(isMobile: true),
          SizedBox(height: responsiveSpacing * 0.75),
        ],
      ),
    );
  }
}

/// Template: Layout tablet para customer (diseño híbrido)
class CustomerTabletTemplate extends StatelessWidget {
  const CustomerTabletTemplate({
    super.key,
    required this.userName,
    required this.commercesList,
    required this.isLoadingCommerces,
    required this.accessTokenHashed,
    this.onCommerceSelected,
  });

  final String userName;
  final String accessTokenHashed;
  final List<UserByRoleModel> commercesList;
  final bool isLoadingCommerces;
  final void Function(UserByRoleModel)? onCommerceSelected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determinar si usar layout vertical u horizontal según orientación
    final isLandscape = screenWidth > screenHeight;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de bienvenida
          CustomerWelcomeHeader(
            userName: userName,
            isMobile: false,
          ),

          const SizedBox(height: 20),

          // Contenido principal adaptativo
          Expanded(
            child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
          ),
        ],
      ),
    );
  }

  /// Layout para tablet en horizontal (similar a desktop pero más compacto)
  Widget _buildLandscapeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna principal - Comercios (70%)
        Expanded(
          flex: 7,
          child: CustomerFeaturedCommerces(
            isMobile: false,
            commercesList: commercesList,
            isLoading: isLoadingCommerces,
            onCommerceSelected: onCommerceSelected,
            accessTokenHashed: accessTokenHashed,
          ),
        ),

        const SizedBox(width: 20),

        // Panel lateral compacto (30%)
        const Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomerSidePanel(),
                SizedBox(height: 16),
                CustomerServiceInfo(isMobile: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Layout para tablet en vertical (más similar a móvil pero con más espacios)
  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comercios principales
          CustomerFeaturedCommerces(
            isMobile: false, // Usar layout más espacioso
            commercesList: commercesList,
            isLoading: isLoadingCommerces,
            onCommerceSelected: onCommerceSelected,
            accessTokenHashed: accessTokenHashed,
          ),

          const SizedBox(height: 24),

          // Row con side panel e info en paralelo
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomerSidePanel(),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomerServiceInfo(isMobile: false),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Template: Layout desktop para customer
class CustomerDesktopTemplate extends StatelessWidget {
  const CustomerDesktopTemplate({
    super.key,
    required this.userName,
    required this.commercesList,
    required this.isLoadingCommerces,
    required this.accessTokenHashed,
    this.onCommerceSelected,
  });

  final String userName;
  final String accessTokenHashed;
  final List<UserByRoleModel> commercesList;
  final bool isLoadingCommerces;
  final void Function(UserByRoleModel)? onCommerceSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de bienvenida (fijo)
        CustomerWelcomeHeader(
          userName: userName,
          isMobile: false,
        ),

        const SizedBox(height: 24),

        // Contenido principal en dos columnas
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna principal - Comercios con scroll
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomerFeaturedCommerces(
                        isMobile: false,
                        commercesList: commercesList,
                        isLoading: isLoadingCommerces,
                        onCommerceSelected: onCommerceSelected,
                        accessTokenHashed: accessTokenHashed,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Panel lateral con scroll independiente
              const Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel de notificaciones y estadísticas
                      CustomerSidePanel(),

                      SizedBox(height: 24),

                      // Información del servicio
                      CustomerServiceInfo(isMobile: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
