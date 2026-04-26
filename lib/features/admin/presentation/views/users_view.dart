import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/user_dialog_handlers.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/users_filter_panel.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/users_kpi_panel.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/users_data_table.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicialización segura del DinningController
    if (Get.isRegistered<DinningController>()) {
      final dinning = Get.find<DinningController>();
      if (dinning.everyListEmpty.value) {
        dinning.getMyDinningInfo();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return const UsersMobileView();
        }

        return Scaffold(
          body: Row(
            children: [
              const SizedBox(
                width: 250,
                child: MenuSide(isMobile: false),
              ),
              const Expanded(child: UsersDesktopView()),
            ],
          ),
        );
      },
    );
  }
}

class UsersMobileView extends StatelessWidget {
  const UsersMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Scaffold(
      drawer: const MenuSide(isMobile: true),
      appBar: AppBar(
        title: const Text('Usuarios'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(FluentIcons.line_horizontal_3_24_regular),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.add_24_regular),
            onPressed: controller.showCreateUserDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarAtom(
              controller: controller.searchController,
              hintText: 'Buscar usuarios...',
              onChanged: controller.onSearchChanged,
              onSubmitted: controller.loadUsers,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.users.isEmpty) {
                return const UsersEmptyState(
                  icon: FluentIcons.people_24_regular,
                  message: 'No hay usuarios',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: UserListTileMolecule(
                        id: user.id,
                        name: user.name,
                        email: user.email,
                        role: user.role,
                        photoUrl: user.photoURL,
                        isEmailVerified: user.isEmailVerified,
                        membership: user.membership?['plan'] as String?,
                        onTap: () => UserDetailsHandler.show(user),
                        onEdit: () => UserEditHandler.show(user),
                        onDelete: () => UserDeleteHandler.show(user),
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

class UsersDesktopView extends StatelessWidget {
  const UsersDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

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
                    title: 'Gestión de Usuarios',
                    onRefresh: controller.loadUsers,
                  ),
                  const SizedBox(height: 24),
                  const UsersFilterPanel(),
                  const SizedBox(height: 16),
                  const UsersKpiPanel(),
                  const SizedBox(height: 24),
                  const UsersDataTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}