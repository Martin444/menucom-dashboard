import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/membership/models/membership_plan_model.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';
import 'package:pu_material/pu_material.dart';
import 'membership_plan_card.dart';

class MembershipPlansSection extends StatelessWidget {
  const MembershipPlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<MembershipController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final plans = controller.plans;
        if (plans.isEmpty) {
          return const _DefaultPlansLayout();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planes Disponibles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fira Code',
                  ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: constraints.maxWidth > 900 ? 1 : 1.3,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final translatedPlan = _translatePlanToSpanish(plan);
                    final planMap = translatedPlan;
                    final planName = plan.name;
                    return MembershipPlanCard(
                      plan: planMap,
                      isCurrentPlan: controller.currentPlan.value == planName,
                      onSubscribe: () => _subscribeToPlan(context, controller, planName),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _subscribeToPlan(BuildContext context, MembershipController controller, String plan) async {
    if (plan == controller.currentPlan.value) return;
    
    final success = await controller.subscribeToPlan(plan);
    if (context.mounted) {
      if (success) {
        final message = plan.toUpperCase() == 'FREE'
            ? 'Plan Gratis activado correctamente'
            : 'Redirigiendo a MercadoPago...';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: PUColors.bgSucces,
          ),
        );
      } else if (controller.errorMessage.value.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage.value),
            backgroundColor: Colors.red.shade700,
          ),
        );
        controller.clearError();
      }
    }
  }

  Map<String, dynamic> _translatePlanToSpanish(MembershipPlanModel plan) {
    final displayNames = {
      'FREE': 'Gratis',
      'PREMIUM': 'Premium',
      'ENTERPRISE': 'Empresarial',
    };
    
    final descriptions = {
      'FREE': 'Perfecto para empezar',
      'PREMIUM': 'Para negocios en crecimiento',
      'ENTERPRISE': 'Para grandes equipos',
    };
    
    final featureTranslations = {
      'FREE': ['Hasta 10 items', '1 catálogo', '7 días analytics'],
      'PREMIUM': ['Items ilimitados', 'Branding personalizado', 'Analíticas avanzadas', 'Soporte prioritario'],
      'ENTERPRISE': ['Todo en Premium', 'Acceso API', 'White label', 'Soporte dedicado'],
    };

    final planKey = plan.name.toUpperCase();
    final json = plan.toJson();
    
    return {
      ...json,
      'displayName': displayNames[planKey] ?? plan.name,
      'description': descriptions[planKey] ?? plan.description,
      'features': featureTranslations[planKey] ?? plan.features,
    };
  }
}

class _DefaultPlansLayout extends StatelessWidget {
  const _DefaultPlansLayout();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembershipController>();
    
    final plansData = [
      {
        'name': 'FREE',
        'displayName': 'Gratis',
        'price': 0.0,
        'description': 'Perfecto para empezar',
        'features': [
          'Hasta 10 items',
          '1 catálogo',
          '7 días analytics',
        ],
        'accentColor': Colors.grey,
      },
      {
        'name': 'PREMIUM',
        'displayName': 'Premium',
        'price': 1499.0,
        'description': 'Para negocios en crecimiento',
        'features': [
          'Items ilimitados',
          'Branding personalizado',
          'Analíticas avanzadas',
          'Soporte prioritario',
        ],
        'accentColor': const Color(0xFF7C3AED), // UI/UX Pro Max Primary
      },
      {
        'name': 'ENTERPRISE',
        'displayName': 'Empresarial',
        'price': 2999.0,
        'description': 'Para grandes equipos',
        'features': [
          'Todo en Premium',
          'Acceso API',
          'White label',
          'Soporte dedicado',
        ],
        'accentColor': const Color(0xFF1E293B), // Dark elegant
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planes Disponibles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Fira Code',
              ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 600
                    ? 2
                    : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: constraints.maxWidth > 900 ? 0.9 : 1.3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: plansData.length,
              itemBuilder: (context, index) {
                final planName = plansData[index]['name']?.toString() ?? '';
                return MembershipPlanCard(
                  plan: plansData[index],
                  isCurrentPlan: controller.currentPlan.value == planName,
                  onSubscribe: () async {
                     if (planName == controller.currentPlan.value) return;
                     final success = await controller.subscribeToPlan(planName);
                     if (context.mounted) {
                       if (success) {
                         final message = planName.toUpperCase() == 'FREE'
                             ? 'Plan Gratis activado correctamente'
                             : 'Redirigiendo a MercadoPago...';
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(message),
                             backgroundColor: PUColors.bgSucces,
                           ),
                         );
                       } else if (controller.errorMessage.value.isNotEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(controller.errorMessage.value),
                             backgroundColor: Colors.red.shade700,
                           ),
                         );
                         controller.clearError();
                       }
                     }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
