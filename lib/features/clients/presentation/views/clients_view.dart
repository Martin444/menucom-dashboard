import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/clients/getx/clients_controller.dart';
import 'package:pickmeup_dashboard/features/clients/presentation/widgets/clients_data_table.dart';
import 'package:pickmeup_dashboard/features/clients/presentation/widgets/clients_filter_panel.dart';
import 'package:pickmeup_dashboard/features/clients/presentation/widgets/clients_kpi_panel.dart';
import 'package:pickmeup_dashboard/features/clients/presentation/widgets/clients_empty_state.dart';
import 'package:pickmeup_dashboard/features/clients/presentation/widgets/client_detail_dialog.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

class ClientsView extends StatelessWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<DinningController>()) {
        final dinning = Get.find<DinningController>();
        if (dinning.everyListEmpty.value) {
          dinning.getMyDinningInfo();
        }
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return const ClientsMobileView();
        }

        return Scaffold(
          body: Row(
            children: [
              const SizedBox(
                width: 250,
                child: MenuSide(isMobile: false),
              ),
              const Expanded(child: ClientsDesktopView()),
            ],
          ),
        );
      },
    );
  }
}

class ClientsMobileView extends StatelessWidget {
  const ClientsMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return Scaffold(
      drawer: const MenuSide(isMobile: true),
      appBar: AppBar(
        title: const Text('Clientes'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(FluentIcons.line_horizontal_3_24_regular),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarAtom(
              controller: controller.searchController,
              hintText: 'Buscar clientes...',
              onChanged: controller.onSearchChanged,
              onSubmitted: controller.loadClients,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.warning_24_regular,
                          size: 48, color: PUColors.bgError),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: PUColors.bgError),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.clients.isEmpty) {
                return const ClientsEmptyState(
                  icon: FluentIcons.people_24_regular,
                  message: 'No hay clientes aún',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadClients,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.clients.length,
                  itemBuilder: (context, index) {
                    final client = controller.clients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: UserListTileMolecule(
                        id: client.id,
                        name: client.name,
                        email: client.email,
                        role: client.role,
                        photoUrl: client.photoURL,
                        isEmailVerified: client.isEmailVerified,
                        membership: client.membership?['plan'] as String?,
                        onTap: () =>
                            Get.dialog(ClientDetailDialog(client: client)),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ClientsDesktopView extends StatelessWidget {
  const ClientsDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientsController>();

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminHeaderMolecule(
                    title: 'Clientes',
                    onRefresh: controller.loadClients,
                    searchHint: 'Buscar clientes...',
                    onSearch: (query) {
                      controller.searchController.text = query;
                      controller.loadClients();
                    },
                  ),
                  const SizedBox(height: 24),
                  const ClientsFilterPanel(),
                  const SizedBox(height: 16),
                  const ClientsKpiPanel(),
                  const SizedBox(height: 24),
                  const ClientsDataTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


