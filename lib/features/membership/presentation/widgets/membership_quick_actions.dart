import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';
import 'membership_action_button.dart';
import 'membership_plans_section.dart';

class MembershipQuickActions extends StatelessWidget {
  const MembershipQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<MembershipController>(
      builder: (controller) {
        if (!controller.isActive.value) return const SizedBox.shrink();

        final status = controller.subscriptionStatus.value ?? '';
        final isPaused = status.toLowerCase() == 'paused';

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: [
            if (!isPaused)
              IntrinsicWidth(
                child: MembershipActionButton(
                  icon: FluentIcons.pause_24_regular,
                  label: 'Pausar',
                  onPressed: () => _showPauseDialog(context, controller),
                ),
              )
            else
              IntrinsicWidth(
                child: MembershipActionButton(
                  icon: FluentIcons.play_24_regular,
                  label: 'Reanudar',
                  onPressed: () => _resumeSubscription(context, controller),
                ),
              ),
            IntrinsicWidth(
              child: MembershipActionButton(
                icon: FluentIcons.arrow_up_24_regular,
                label: 'Cambiar Plan',
                onPressed: () => _showUpgradeSheet(context, controller),
              ),
            ),
            IntrinsicWidth(
              child: MembershipActionButton(
                icon: FluentIcons.dismiss_24_regular,
                label: 'Cancelar',
                color: PUColors.bgError,
                onPressed: () => _showCancelDialog(context, controller),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPauseDialog(BuildContext context, MembershipController controller) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pausar Suscripción'),
        content: const Text(
          '¿Estás seguro de que quieres pausar tu suscripción? '
          'Podrás reanudarla cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.pauseSubscription();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: const Text('Suscripción pausada'),
                    backgroundColor: PUColors.bgSucces,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Pausar'),
          ),
        ],
      ),
    );
  }

  Future<void> _resumeSubscription(BuildContext context, MembershipController controller) async {
    final success = await controller.resumeSubscription();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: const Text('Suscripción reactivada'),
          backgroundColor: PUColors.bgSucces,
        ),
      );
    }
  }

  Future<void> _showCancelDialog(BuildContext context, MembershipController controller) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Suscripción'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar tu suscripción? '
          'Perderás todos los beneficios premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mantener'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.cancelSubscription();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: const Text('Suscripción cancelada'),
                    backgroundColor: PUColors.bgError,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PUColors.bgError,
            ),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context, MembershipController controller) {
    // We defer the loading of the plans section to MembershipPlansSection for atomic design
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Cambiar Plan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  MembershipPlansSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
