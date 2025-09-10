import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import '../organisms/customer_organisms.dart';
import '../molecules/customer_molecules.dart';

/// TEMPLATES - Layouts y estructuras de página

/// Template: Layout móvil para customer
class CustomerMobileTemplate extends StatelessWidget {
  const CustomerMobileTemplate({
    super.key,
    required this.userName,
    required this.commercesList,
    required this.isLoadingCommerces,
    this.onCommerceSelected,
  });

  final String userName;
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
          isMobile: true,
        ),

        const SizedBox(height: 24),

        // Contenido principal con scroll
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de comercios con altura fija para scroll independiente
                SizedBox(
                  height: 400, // Altura fija para permitir scroll interno
                  child: CustomerFeaturedCommerces(
                    isMobile: true,
                    commercesList: commercesList,
                    isLoading: isLoadingCommerces,
                    onCommerceSelected: onCommerceSelected,
                  ),
                ),

                const SizedBox(height: 24),

                // Información del servicio
                const CustomerServiceInfo(isMobile: true),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
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
    this.onCommerceSelected,
  });

  final String userName;
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
                child: CustomerFeaturedCommerces(
                  isMobile: false,
                  commercesList: commercesList,
                  isLoading: isLoadingCommerces,
                  onCommerceSelected: onCommerceSelected,
                ),
              ),

              const SizedBox(width: 24),

              // Panel lateral con scroll independiente
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
