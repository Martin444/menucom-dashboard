import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_assets.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class CatalogEmptyState extends StatelessWidget {
  const CatalogEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                PUImages.noDataImageSvg,
                height: 180,
                errorBuilder: (context, error, stackTrace) => Icon(
                  FluentIcons.folder_24_regular,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Comienza tu aventura digital',
                style: PuTextStyle.title1.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Aún no tienes catálogos. Sigue estos pasos para empezar a vender hoy mismo.',
                style: PuTextStyle.description1.copyWith(
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              const GettingStartedSteps(),
              const SizedBox(height: 48),
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 320,
                ),
                child: ButtonPrimary(
                  title: 'Crear mi primer catálogo',
                  onPressed: () {
                    Get.toNamed(PURoutes.REGISTER_WARDROBES);
                  },
                  load: false,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Solo te tomará un par de minutos.',
                style: PuTextStyle.description2.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GettingStartedSteps extends StatelessWidget {
  const GettingStartedSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        StepCard(
          icon: FluentIcons.form_24_regular,
          title: '1. Crea tu catálogo',
          description:
              'Define el nombre, categoría y una foto de portada atractiva.',
          color: Color(0xFF3B82F6),
        ),
        StepCard(
          icon: FluentIcons.add_circle_24_regular,
          title: '2. Añade productos',
          description:
              'Sube fotos, precios y detalles de lo que ofreces a tus clientes.',
          color: Color(0xFF10B981),
        ),
        StepCard(
          icon: FluentIcons.share_24_regular,
          title: '3. Comparte el link',
          description:
              'Envía tu catálogo digital por WhatsApp o redes sociales.',
          color: Color(0xFFF59E0B),
        ),
      ],
    );
  }
}

class StepCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const StepCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}