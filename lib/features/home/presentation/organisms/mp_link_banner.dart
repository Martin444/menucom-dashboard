import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/dinning_controller.dart';
import '../molecules/mp_banner_header.dart';
import '../molecules/mp_banner_benefits.dart';
import '../molecules/mp_banner_actions.dart';

/// Organismo principal que gestiona el banner de vinculación con Mercado Pago.
class MPLinkBanner extends GetView<DinningController> {
  const MPLinkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Solo mostrar si no está vinculado
      if (controller.isLinkedToMP.value) return const SizedBox.shrink();

      return LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isMobile = width < 700;
          final bool isSmallMobile = width < 450;

          return FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF009EE3),
                    Color(0xFF007EB5),
                    Color(0xFF005E87),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF009EE3).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Patrón de fondo sutil
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Opacity(
                        opacity: 0.1,
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 250,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(isMobile ? 24 : 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MPBannerHeader(
                            controller: controller,
                            isMobile: isMobile,
                            isSmallMobile: isSmallMobile,
                          ),
                          const SizedBox(height: 24),
                          const MPBannerBenefits(),
                          const SizedBox(height: 32),
                          MPBannerActions(
                            isMobile: isMobile,
                            onLink: () => controller.vincularMercadoPago(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
