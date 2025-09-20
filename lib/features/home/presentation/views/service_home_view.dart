import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';

/// Vista para usuarios con rol `service`.
/// Es un widget sencillo y responsivo que acepta `isMobile` para mantener
/// la misma firma que otras vistas en la carpeta `views`.
class ServiceHomeView extends StatelessWidget {
  const ServiceHomeView({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final padding = isMobile ? 16.0 : 24.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: PUColors.bgItem,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: isMobile ? 8 : 16),
          Icon(
            Icons.build_rounded,
            size: isMobile ? 56 : 80,
            color: PUColors.iconColor,
          ),
          SizedBox(height: isMobile ? 12 : 20),
          Text(
            'Área de Servicios',
            style: PuTextStyle.title2.copyWith(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.w700,
              color: PUColors.textColor3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Aquí podrás gestionar las tareas y solicitudes asignadas al equipo de servicio.',
            style: PuTextStyle.description1.copyWith(
              fontSize: isMobile ? 14 : 16,
              color: PUColors.textColor1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 28),
          ElevatedButton.icon(
            onPressed: () {
              // Placeholder: navegar a la sección de detalles de servicio
            },
            icon: const Icon(Icons.list_alt_outlined),
            label: const Text('Ver solicitudes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PUColors.bgButton,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 12 : 16,
                horizontal: isMobile ? 20 : 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
