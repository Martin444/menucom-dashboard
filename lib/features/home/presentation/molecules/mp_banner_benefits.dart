import 'package:flutter/material.dart';
import '../atoms/mp_benefit_badge.dart';

/// Sección de beneficios con badges.
class MPBannerBenefits extends StatelessWidget {
  const MPBannerBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: const [
        MPBenefitBadge(
          icon: Icons.flash_on_rounded,
          text: 'Cobros inmediatos',
        ),
        MPBenefitBadge(
          icon: Icons.verified_user_rounded,
          text: 'Pagos seguros',
        ),
        MPBenefitBadge(
          icon: Icons.auto_graph_rounded,
          text: 'Gestión automática',
        ),
      ],
    );
  }
}
