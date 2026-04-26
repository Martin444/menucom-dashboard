import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/model/user_by_role_model.dart';
import 'package:menu_dart_api/by_feature/membership/models/billing_details_model.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'dialog_header_atom.dart';

class BillingDetailsDialog extends GetView<UsersController> {
  final UserByRoleModel user;

  const BillingDetailsDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeaderAtom(
              title: 'Detalles de Facturación',
              icon: FluentIcons.receipt_24_regular,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: PUSpacing.lg,
                child: Obx(() {
                  if (controller.isLoadingBilling.value) {
                    return Center(
                      child: Padding(
                        padding: PUSpacing.xl,
                        child: const CircularProgressIndicator(),
                      ),
                    );
                  }

                  final details = controller.currentBillingDetails.value;
                  if (details == null) {
                    return Center(
                      child: Padding(
                        padding: PUSpacing.xl,
                        child: const Text('No se pudieron cargar los detalles de facturación.'),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryCard(details),
                      const SizedBox(height: 16),
                      _buildPriceSection(details),
                      const SizedBox(height: 16),
                      if (details.billingMode == BillingMode.auto) 
                        _buildAutoBillingSection(details),
                      if (details.billingMode == BillingMode.manual) 
                        _buildManualBillingSection(details),
                      if (details.billingMode == BillingMode.none)
                        _buildNoBillingSection(details),
                      const SizedBox(height: 16),
                      _buildHistorySection(details),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BillingDetailsModel details) {
    return Container(
      padding: PUSpacing.md,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usuario: ${user.name ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Plan: ${details.currentPlan.displayName} (base: \$${details.currentPlan.basePrice})',
            style: const TextStyle(),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Modo: '),
                  _buildModeBadge(details.billingMode),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showChangeModeOptions(details),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Cambiar Modo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeBadge(BillingMode mode) {
    Color bgColor;
    Color textColor;
    String text;

    switch (mode) {
      case BillingMode.auto:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        text = 'AUTO ✓';
      case BillingMode.manual:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        text = 'MANUAL';
      case BillingMode.none:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        text = 'NINGUNO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildPriceSection(BillingDetailsModel details) {
    return _buildSectionCard(
      title: 'PRECIO',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${details.effectivePrice}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (details.adminSetPrice != null)
                const Text(
                  '(override admin)',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showChangeAmountDialog(details),
            child: const Text('Cambiar Monto'),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoBillingSection(BillingDetailsModel details) {
    final autoInfo = details.autoBilling;
    return _buildSectionCard(
      title: 'AUTO-BILLING (Mercado Pago)',
      child: autoInfo == null
          ? const Text('Sin información de auto-billing')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Preapproval:', autoInfo.mpPreapprovalId ?? 'N/A'),
                _buildInfoRow('Estado:', autoInfo.status ?? 'N/A'),
                if (autoInfo.nextBillingDate != null)
                  _buildInfoRow('Próximo cobro:', controller.formatDate(autoInfo.nextBillingDate)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (autoInfo.status == 'authorized')
                      OutlinedButton(
                        onPressed: () => controller.pauseSubscription(details.membershipId),
                        child: const Text('Pausar'),
                      )
                    else if (autoInfo.status == 'paused')
                      ElevatedButton(
                        onPressed: () => controller.resumeSubscription(details.membershipId),
                        child: const Text('Reanudar'),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildManualBillingSection(BillingDetailsModel details) {
    final manualInfo = details.manualBilling;
    return _buildSectionCard(
      title: 'FACTURACIÓN MANUAL',
      child: manualInfo == null
          ? Column(
              children: [
                const Text('No hay link de pago pendiente.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showGenerateLinkDialog(details),
                  child: const Text('Generar Link de Pago'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Estado:', manualInfo.pendingPaymentId ?? 'N/A'),
                if (manualInfo.pendingPaymentLink != null)
                  _buildInfoRow('Link:', manualInfo.pendingPaymentLink!),
                if (manualInfo.pendingPaymentExpiresAt != null)
                  _buildInfoRow('Expira:', controller.formatDate(manualInfo.pendingPaymentExpiresAt)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _showGenerateLinkDialog(details),
                      child: const Text('Nuevo Link'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildNoBillingSection(BillingDetailsModel details) {
    return _buildSectionCard(
      title: 'ACCIONES DE FACTURACIÓN',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _showGenerateLinkDialog(details),
            child: const Text('Generar Link de Pago'),
          ),
          OutlinedButton(
            onPressed: () => _showEnableAutoBillingDialog(details),
            child: const Text('Habilitar Auto-Billing'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BillingDetailsModel details) {
    return _buildSectionCard(
      title: 'HISTORIAL DE PAGOS',
      child: details.paymentHistory.isEmpty
          ? const Text('No hay pagos registrados', style: TextStyle(color: Colors.grey))
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.paymentHistory.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final payment = details.paymentHistory[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(controller.formatDate(payment.date)),
                    Text('\$${payment.amount}'),
                    Row(
                      children: [
                        Icon(
                          payment.status == 'approved' ? Icons.check_circle : Icons.info,
                          color: payment.status == 'approved' ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(payment.status, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: PUSpacing.md,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showChangeModeOptions(BillingDetailsModel details) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: PUSpacing.lg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Cambiar Modo de Facturación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (details.billingMode != BillingMode.auto)
              ListTile(
                leading: Icon(Icons.autorenew, color: Colors.green.shade600),
                title: const Text('Migrar a Auto-Billing'),
                onTap: () {
                  Get.back();
                  _showEnableAutoBillingDialog(details);
                },
              ),
            if (details.billingMode != BillingMode.manual)
              ListTile(
                leading: Icon(Icons.receipt, color: Colors.orange.shade600),
                title: const Text('Migrar a Manual'),
                onTap: () {
                  Get.back();
                  _showConfirmMigrateManual(details);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showConfirmMigrateManual(BillingDetailsModel details) {
    Get.dialog(
      AlertDialog(
        title: const Text('Migrar a Facturación Manual'),
        content: const Text('¿Estás seguro que deseas desactivar el cobro automático para esta membresía? Tendrás que generar links de pago manualmente.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.migrateToManualBilling(details.membershipId);
            },
            child: const Text('Sí, Migrar'),
          ),
        ],
      ),
    );
  }

  void _showChangeAmountDialog(BillingDetailsModel details) {
    final amountController = TextEditingController(text: details.effectivePrice.toString());
    Get.dialog(
      AlertDialog(
        title: const Text('Cambiar Monto de Facturación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el nuevo monto para esta membresía:'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: 'Ej. 12000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final newAmount = double.tryParse(amountController.text);
              if (newAmount != null) {
                Get.back();
                controller.changeBillingAmount(membershipId: details.membershipId, newAmount: newAmount);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showGenerateLinkDialog(BillingDetailsModel details) {
    Get.snackbar('En desarrollo', 'Modal para generar link pendiente');
  }

  void _showEnableAutoBillingDialog(BillingDetailsModel details) {
    Get.snackbar('En desarrollo', 'Modal para habilitar auto-billing pendiente');
  }
}