import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No hay planes disponibles en este momento.',
                style: TextStyle(color: PUColors.textColor2),
              ),
            ),
          );
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
                    final planMap = plan.toJson();
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
        final message =
            plan.toUpperCase() == 'FREE' ? 'Plan Gratis activado correctamente' : 'Redirigiendo a MercadoPago...';
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
}
