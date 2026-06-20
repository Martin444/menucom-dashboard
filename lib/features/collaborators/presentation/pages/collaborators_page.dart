import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user_roles/my_team/model/my_team_response.dart';
import 'package:pu_material/pu_material.dart';
import '../../../home/presentation/widget/menu_side.dart';
import '../controllers/collaborators_controller.dart';
import '../widgets/widgets.dart';

class CollaboratorsPage extends StatelessWidget {
  const CollaboratorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CollaboratorsController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        if (isMobile) {
          return _buildMobileLayout(controller);
        }
        return _buildDesktopLayout(controller);
      },
    );
  }

  Widget _buildDesktopLayout(CollaboratorsController controller) {
    return Scaffold(
      body: Row(
        children: [
          const SizedBox(width: 250, child: MenuSide(isMobile: false)),
          Expanded(child: _buildBody(controller)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(CollaboratorsController controller) {
    return Scaffold(
      drawer: const MenuSide(isMobile: true),
      appBar: AppBar(
        title: const Text('Colaboradores'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(FluentIcons.navigation_24_regular),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(CollaboratorsController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.teamUsers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.teamUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.errorMessage.value,
                  style: const TextStyle(color: PUColors.bgError)),
              const SizedBox(height: 16),
              ButtonPrimary(
                title: 'Reintentar',
                onPressed: controller.loadTeam,
                load: controller.isLoading.value,
              ),
            ],
          ),
        );
      }
      if (controller.teamUsers.isEmpty) {
        return CollaboratorEmptyStateAtom(
          onAdd: () => _showAssignRoleDialog(controller),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadTeam,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            if (isMobile) return _buildMobileList(controller);
            return _buildDesktopContent(controller);
          },
        ),
      );
    });
  }

  Widget _buildDesktopContent(CollaboratorsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminHeaderMolecule(
            title: 'Colaboradores',
            onRefresh: controller.loadTeam,
            onAdd: () => _showAssignRoleDialog(controller),
            searchHint: 'Buscar colaborador...',
            onSearch: controller.onSearchChanged,
          ),
          const SizedBox(height: 24),
          CollaboratorKpiOrganism(
            totalCount: controller.totalCount,
            ownerCount: controller.ownerCount,
            managerCount: controller.managerCount,
            staffCount: controller.staffCount,
          ),
          const SizedBox(height: 24),
          if (controller.filteredUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No se encontraron colaboradores',
                    style: TextStyle(
                        color: PUColors.textColorMuted, fontSize: 14)),
              ),
            )
          else
            CollaboratorTableOrganism(
              users: controller.paginatedUsers,
              currentPage: controller.currentPage.value,
              totalPages: controller.totalPages,
              onPageChanged: controller.goToPage,
              onEdit: (user) => _showEditRoleDialog(controller, user),
              onDelete: (user) => _confirmRemove(controller, user),
              onToggleActive: (user, active) =>
                  _toggleActive(controller, user, active),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileList(CollaboratorsController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child:           SearchBarAtom(
            controller: controller.searchController,
            hintText: 'Buscar colaborador...',
            onChanged: controller.onSearchChanged,
          ),
        ),
        Expanded(
          child: controller.filteredUsers.isEmpty
              ? const Center(
                  child: Text('No se encontraron colaboradores',
                      style: TextStyle(color: PUColors.textColorMuted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CollaboratorCardMolecule(
                        user: user,
                        onEdit: () => _showEditRoleDialog(controller, user),
                        onDelete: () => _confirmRemove(controller, user),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAssignRoleDialog(CollaboratorsController controller) {
    Get.dialog(const AssignRoleDialogMolecule()).then((result) async {
      if (result is! Map) return;
      final userId = result['userId'];
      final role = result['role'];
      if (userId is! String || role is! String) return;
      final error = await controller.assignRole(userId: userId, role: role);
      if (error != null && Get.context != null) {
        Get.snackbar('Error', error,
            backgroundColor: PUColors.bgError, colorText: Colors.white);
      }
    });
  }

  void _showEditRoleDialog(
      CollaboratorsController controller, TeamUser user) {
    final currentRole =
        user.roles.isNotEmpty ? user.roles.first.role : 'operator';
    Get.dialog(
      AssignRoleDialogMolecule(
        initialEmail: user.email,
        initialRole: currentRole,
        isEditing: true,
      ),
    ).then((result) async {
      if (result is! Map) return;
      final newRole = result['role'];
      if (newRole is! String || newRole == currentRole) return;
      final error = await controller.changeRole(
        userId: user.userId,
        oldRole: currentRole,
        newRole: newRole,
      );
      if (error != null && Get.context != null) {
        Get.snackbar('Error', error,
            backgroundColor: PUColors.bgError, colorText: Colors.white);
      }
    });
  }

  void _confirmRemove(CollaboratorsController controller, TeamUser user) {
    if (user.roles.isEmpty) return;
    Get.dialog(
      AlertDialog(
        title: const Text('Remover colaborador'),
        content: Text('¿Estás seguro de remover a "${user.name}" del equipo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ButtonPrimary(
            title: 'Remover',
            onPressed: () async {
              Get.back();
              for (final r in user.roles) {
                final error = await controller.removeCollaborator(
                  userId: user.userId,
                  role: r.role,
                );
                if (error != null && Get.context != null) {
                  Get.snackbar('Error', error,
                      backgroundColor: PUColors.bgError,
                      colorText: Colors.white);
                  return;
                }
              }
            },
            load: false,
          ),
        ],
      ),
    );
  }

  void _toggleActive(
      CollaboratorsController controller, TeamUser user, bool active) {
    if (user.roles.isEmpty) return;
    controller.updateUserRoleStatus(
      roleId: user.roles.first.id,
      isActive: active,
    ).then((error) {
      if (error != null && Get.context != null) {
        Get.snackbar('Error', error,
            backgroundColor: PUColors.bgError, colorText: Colors.white);
      }
    });
  }
}
