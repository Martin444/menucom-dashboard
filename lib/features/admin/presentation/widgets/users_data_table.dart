import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/user_dialog_handlers.dart';

/// Tabla de datos de la vista de usuarios con paginación.
/// Extraído de UsersDesktopView._buildDataTable para cumplir Atomic Design.
class UsersDataTable extends StatelessWidget {
  const UsersDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const ContainerAtom(
          variant: ContainerVariant.card,
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.users.isEmpty) {
        return const ContainerAtom(
          variant: ContainerVariant.card,
          padding: EdgeInsets.all(32),
          child: UsersEmptyState(
            icon: FluentIcons.people_24_regular,
            message: 'No hay usuarios que coincidan con los filtros',
          ),
        );
      }

      return AdminDataTableMolecule(
        headers: const [
          'Usuario',
          'Email',
          'Rol',
          'Membresía',
          'Estado',
          'Acciones'
        ],
        showPagination: true,
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages.value,
        onPageChanged: controller.goToPage,
        rows: controller.users.map((user) {
          final plan =
              (user.membership?['plan'] as String?) ?? 'Sin plan';

          return AdminTableRow([
            WidgetTableCell(
              Row(
                children: [
                  UserAvatarSmall(photoUrl: user.photoURL),
                  const SizedBox(width: 12),
                  Text(
                    user.name ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            TextTableCell(user.email ?? '-'),
            TextTableCell(user.role ?? '-'),
            BadgeTableCell(
              plan.toUpperCase(),
              user.membership != null
                  ? PUColors.primaryColor
                  : PUColors.textColorMuted,
            ),
            BadgeTableCell(
              user.isEmailVerified == true ? 'VERIFICADO' : 'PENDIENTE',
              user.isEmailVerified == true
                  ? PUColors.ctaSuccess
                  : PUColors.bgError,
            ),
            WidgetTableCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        const Icon(FluentIcons.edit_24_regular, size: 20),
                    onPressed: () => UserEditHandler.show(user),
                    color: PUColors.textColorMuted,
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.delete_24_regular,
                        size: 20),
                    onPressed: () => UserDeleteHandler.show(user),
                    color: PUColors.bgError,
                  ),
                  IconButton(
                    icon:
                        const Icon(FluentIcons.eye_24_regular, size: 20),
                    onPressed: () => UserDetailsHandler.show(user),
                    color: PUColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      );
    });
  }
}

/// Avatar pequeño del usuario en la tabla.
/// Extraído de UsersDesktopView._buildAvatar para cumplir Atomic Design.
class UserAvatarSmall extends StatelessWidget {
  final String? photoUrl;

  const UserAvatarSmall({super.key, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: PUColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  FluentIcons.person_24_regular,
                  size: 16,
                  color: PUColors.primaryColor,
                ),
              )
            : const Icon(
                FluentIcons.person_24_regular,
                size: 16,
                color: PUColors.primaryColor,
              ),
      ),
    );
  }
}

/// Estado vacío de la tabla de usuarios.
/// Extraído de _EmptyState para cumplir un archivo por clase (shared).
class UsersEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const UsersEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: PUColors.textColorMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: PUColors.textColorMuted,
            ),
          ),
        ],
      ),
    );
  }
}
