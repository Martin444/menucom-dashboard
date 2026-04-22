import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pickmeup_dashboard/features/membership/getx/membership_controller.dart';
import 'package:pu_material/pu_material.dart';

class MembershipBillingHistory extends StatelessWidget {
  const MembershipBillingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<MembershipController>(
      builder: (controller) {
        final history = controller.billingHistory;
        
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
                    FluentIcons.receipt_24_regular,
                    color: PUColors.accentColor, // Gold accent
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Historial de Facturación',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Fira Code',
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          FluentIcons.document_24_regular,
                          color: PUColors.iconColor.withValues(alpha: 0.5),
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay facturas aún',
                          style: TextStyle(
                            color: PUColors.textColor1,
                            fontSize: 16,
                            fontFamily: 'Fira Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...history.map((item) {
                  final amount = (item['amount'] as num?)?.toDouble() ?? 0;
                  final date = item['paidAt']?.toString() ?? item['date']?.toString() ?? '';
                  final status = item['status']?.toString() ?? 'pending';
                  final invoiceUrl = item['invoiceUrl']?.toString();

                  Color statusColor;
                  IconData statusIcon;
                  switch (status.toLowerCase()) {
                    case 'approved':
                      statusColor = PUColors.bgSucces;
                      statusIcon = FluentIcons.checkmark_circle_24_filled;
                      break;
                    case 'pending':
                      statusColor = Colors.orange;
                      statusIcon = FluentIcons.clock_24_filled;
                      break;
                    default:
                      statusColor = PUColors.bgError;
                      statusIcon = FluentIcons.dismiss_circle_24_filled;
                  }

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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            statusIcon,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                date.isNotEmpty ? _formatDate(date) : 'Fecha no disponible',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Fira Sans',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getPaymentStatusLabel(status),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Fira Sans',
                          ),
                        ),
                        if (invoiceUrl != null) ...[
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              FluentIcons.arrow_download_24_regular,
                              color: PUColors.accentColor,
                              size: 22,
                            ),
                            tooltip: 'Descargar factura',
                          ),
                        ],
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

  String _getPaymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Aprobado';
      case 'pending':
        return 'Pendiente';
      case 'rejected':
        return 'Rechazado';
      default:
        return status;
    }
  }
}
