import 'package:flutter/material.dart';
import 'package:pu_material/pu_material.dart';
import '../../controllers/dinning_controller.dart';
import '../atoms/mp_refresh_button.dart';

/// Encabezado del banner de Mercado Pago con título y descripción.
class MPBannerHeader extends StatelessWidget {
  final DinningController controller;
  final bool isMobile;
  final bool isSmallMobile;

  const MPBannerHeader({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.isSmallMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono Premium
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFF009EE3),
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        // Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Impulsá tu negocio con Mercado Pago',
                style: PuTextStyle.title2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isSmallMobile ? 20 : 26,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vincular tu cuenta te permite aceptar pagos automáticos y gestionar tus ventas en tiempo real.',
                style: PuTextStyle.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isSmallMobile ? 13 : 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 20),
          MPRefreshButton(controller: controller),
        ],
        // Botón de cerrar
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => controller.setBannerVisible(false),
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 24,
          ),
          tooltip: 'Ocultar banner',
          splashRadius: 20,
        ),
      ],
    );
  }
}
