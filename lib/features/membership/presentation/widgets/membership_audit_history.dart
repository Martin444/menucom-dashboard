import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';
import 'package:pu_material/pu_material.dart';

class MembershipAuditHistory extends StatelessWidget {
  const MembershipAuditHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<MembershipController>(
      builder: (controller) {
        final audit = controller.auditHistory;
        if (audit.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PUColors.bgItem,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PUColors.borderInputColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    FluentIcons.history_24_regular,
                    color: Color(0xFF7C3AED),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Historial de Actividad',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fira Code',
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...audit.take(5).map((item) {
                final action = item['action']?.toString() ?? '';
                final timestamp = item['timestamp']?.toString() ?? '';
                final details = item['details']?.toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PUColors.bgInput.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FluentIcons.info_24_regular,
                          color: Color(0xFF7C3AED),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                fontFamily: 'Fira Sans',
                              ),
                            ),
                            if (details != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  details,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: PUColors.textColor1,
                                    fontFamily: 'Fira Sans',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (timestamp.isNotEmpty) ...[
                         const SizedBox(width: 12),
                         Text(
                          _formatDate(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: PUColors.textColor1,
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
