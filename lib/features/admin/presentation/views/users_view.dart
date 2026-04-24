import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

void _ensureDinningControllerReady() {
  if (Get.isRegistered<DinningController>()) {
    final controller = Get.find<DinningController>();
    if (controller.everyListEmpty.value) {
      controller.getMyDinningInfo();
    }
  }
}

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    _ensureDinningControllerReady();

    try {
      if (Get.isRegistered<DinningController>()) {
        Get.find<DinningController>();
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<AdminDashboardController>()) {
        final adminController = Get.find<AdminDashboardController>();
        if (adminController.selectedIndex.value != 1) {
          adminController.selectedIndex.value = 1;
        }
      }
    } catch (_) {}

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 768;

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
                return EmptyStateMolecule(
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
                        onTap: () => controller.showUserDetails(user),
                        onDelete: () => controller.confirmDeleteUser(user),
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
                  _buildFilters(controller),
                  const SizedBox(height: 16),
                  _buildKPIs(controller),
                  const SizedBox(height: 24),
                  _buildDataTable(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(UsersController controller) {
    return ContainerAtom(
      variant: ContainerVariant.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SearchBarAtom(
                  controller: controller.searchController,
                  hintText: 'Buscar por nombre o email...',
                  onChanged: (_) {},
                  onSubmitted: controller.loadUsers,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(FluentIcons.add_24_regular),
                onPressed: controller.showCreateUserDialog,
                style: IconButton.styleFrom(
                  backgroundColor: PUColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => FilterChipsRowMolecule(
                chips: [
                  FilterChipData(
                    label: 'Todos',
                    value: '',
                    selected: controller.selectedPlan.value.isEmpty,
                    onSelected: (_) => controller.filterByPlan(''),
                  ),
                  FilterChipData(
                    label: 'Free',
                    value: 'free',
                    selected: controller.selectedPlan.value == 'free',
                    onSelected: (_) => controller.filterByPlan('free'),
                  ),
                  FilterChipData(
                    label: 'Premium',
                    value: 'premium',
                    selected: controller.selectedPlan.value == 'premium',
                    onSelected: (_) => controller.filterByPlan('premium'),
                  ),
                  FilterChipData(
                    label: 'Enterprise',
                    value: 'enterprise',
                    selected: controller.selectedPlan.value == 'enterprise',
                    onSelected: (_) => controller.filterByPlan('enterprise'),
                  ),
                ],
              )),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 8,
                children: [
                  FilterChipAtom(
                    label: 'Con membresía activa',
                    selected: controller.withActiveMembership.value,
                    onSelected: (_) => controller.toggleActiveMembership(),
                  ),
                  FilterChipAtom(
                    label: 'Con cuenta MP',
                    selected: controller.withVinculedAccount.value,
                    onSelected: (_) => controller.toggleVinculedAccount(),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildKPIs(UsersController controller) {
    return Obx(() => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Total Usuarios',
                value: '${controller.totalCount.value}',
                icon: FluentIcons.people_24_regular,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Con Membresía',
                value: '${controller.activeMembershipCount.value}',
                icon: FluentIcons.person_24_regular,
                iconColor: PUColors.primaryColor,
                iconBackground: PUColors.primaryBlueLight,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Cuentas MP',
                value: '${controller.vinculedCount.value}',
                icon: FluentIcons.wallet_24_regular,
                iconColor: PUColors.primaryBlue,
                iconBackground: PUColors.primaryBlueLight,
              ),
            ),
            SizedBox(
              width: 200,
              child: AdminKpiMolecule(
                title: 'Verificados',
                value: '${controller.verifiedCount.value}',
                icon: FluentIcons.checkmark_circle_24_regular,
                iconColor: PUColors.ctaSuccess,
                iconBackground: PUColors.bgSuccess,
              ),
            ),
          ],
        ));
  }

  Widget _buildDataTable(UsersController controller) {
    return ContainerAtom(
      variant: ContainerVariant.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const UserTableHeaderMolecule(),
          const Divider(),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.users.isEmpty) {
              return EmptyStateMolecule(
                icon: FluentIcons.people_24_regular,
                message: 'No hay usuarios que coincidan con los filtros',
              );
            }

            return Column(
              children: controller.users.map((user) {
                return Column(
                  children: [
                    UserTableRowMolecule(
                      id: user.id,
                      name: user.name,
                      email: user.email,
                      phone: user.phone,
                      role: user.role,
                      photoUrl: user.photoURL,
                      isEmailVerified: user.isEmailVerified,
                      hasActiveMembership: user.membership != null,
                      createdAt: user.createAt,
                      onTap: () => controller.showUserDetails(user),
                      onEdit: () => controller.showEditUserDialog(user),
                      onDelete: () => controller.confirmDeleteUser(user),
                    ),
                    const Divider(height: 1),
                  ],
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 16),
          Obx(() => PaginationMolecule(
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages.value,
                totalItems: controller.totalCount.value,
                itemsPerPage: controller.itemsPerPage.value,
                onPageChanged: controller.goToPage,
                onItemsPerPageChanged: controller.changeItemsPerPage,
              )),
        ],
      ),
    );
  }
}

class EmptyStateMolecule extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? action;

  const EmptyStateMolecule({
    super.key,
    required this.icon,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: PUColors.textColorMuted,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: PUColors.textColorMuted,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
