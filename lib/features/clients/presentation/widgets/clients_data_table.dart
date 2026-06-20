import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/clients/getx/clients_controller.dart';
import 'package:pickmeup_dashboard/features/clients/presentation/widgets/client_detail_dialog.dart';
import 'package:pickmeup_dashboard/features/clients/presentation/widgets/clients_empty_state.dart';

class ClientsDataTable extends StatelessWidget {
  const ClientsDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const ContainerAtom(
          variant: ContainerVariant.card,
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return ContainerAtom(
          variant: ContainerVariant.card,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.warning_24_regular,
                  size: 48, color: PUColors.bgError),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(color: PUColors.bgError),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (controller.clients.isEmpty) {
        return ContainerAtom(
          variant: ContainerVariant.card,
          padding: const EdgeInsets.all(32),
          child: const ClientsEmptyState(
            icon: FluentIcons.people_24_regular,
            message: 'No se encontraron clientes',
          ),
        );
      }

      final paginatedClients = controller.paginatedClients;

      return Column(
        children: [
          AdminDataTableMolecule(
            headers: const [
              'Cliente',
              'Email',
              'Teléfono',
              'Membresía',
              'Miembro desde',
              'Acciones'
            ],
            showPagination: true,
            currentPage: controller.currentPage.value,
            totalPages: controller.totalPages.value,
            onPageChanged: controller.goToPage,
            rows: paginatedClients.map((client) {
              final plan = client.membership?['plan'] as String?;
              return AdminTableRow([
                WidgetTableCell(
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: PUColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: client.photoURL != null &&
                                  client.photoURL!.isNotEmpty
                              ? Image.network(
                                  client.photoURL!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    FluentIcons.person_24_regular,
                                    size: 18,
                                    color: PUColors.primaryColor,
                                  ),
                                )
                              : const Icon(
                                  FluentIcons.person_24_regular,
                                  size: 18,
                                  color: PUColors.primaryColor,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        client.name ?? 'Sin nombre',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                TextTableCell(client.email ?? '-'),
                TextTableCell(client.phone ?? '-'),
                BadgeTableCell(
                  plan?.toUpperCase() ?? 'SIN PLAN',
                  plan != null
                      ? PUColors.primaryColor
                      : PUColors.textColorMuted,
                ),
                TextTableCell(
                  controller.formatDate(client.createAt),
                  style: const TextStyle(
                      color: PUColors.textColorMuted, fontSize: 13),
                ),
                WidgetTableCell(
                  IconButton(
                    icon: const Icon(FluentIcons.eye_24_regular, size: 20),
                    onPressed: () => Get.dialog(
                        ClientDetailDialog(client: client)),
                    color: PUColors.primaryBlue,
                    tooltip: 'Ver detalle',
                    splashRadius: 20,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ],
      );
    });
  }
}
