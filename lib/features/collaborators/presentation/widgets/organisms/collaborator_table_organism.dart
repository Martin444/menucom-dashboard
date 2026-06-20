import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/user_roles/my_team/model/my_team_response.dart';
import 'package:pu_material/pu_material.dart';
import '../atoms/collaborator_role_badge_atom.dart';

class CollaboratorTableOrganism extends StatelessWidget {
  final List<TeamUser> users;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final void Function(TeamUser user)? onEdit;
  final void Function(TeamUser user)? onDelete;
  final void Function(TeamUser user, bool active)? onToggleActive;

  const CollaboratorTableOrganism({
    super.key,
    required this.users,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPageChanged,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return AdminDataTableMolecule(
      headers: const ['Colaborador', 'Email', 'Rol', 'Estado', 'Acciones'],
      rows: users.map((user) {
        final isActive = user.roles.any((r) => r.isActive);
        final isOwner = user.roles.any(
            (r) => r.role.toLowerCase() == 'owner');

        return AdminTableRow([
          WidgetTableCell(
            Row(
              children: [
                UserAvatarAtom(
                  size: 36,
                  icon: FluentIcons.person_24_regular,
                ),
                const SizedBox(width: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextTableCell(user.email),
          WidgetTableCell(
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: user.roles
                  .map((r) => CollaboratorRoleBadgeAtom(
                        role: r.role,
                        isActive: r.isActive,
                      ))
                  .toList(),
            ),
          ),
          SwitchTableCell(
            isActive,
            onChanged: !isOwner && onToggleActive != null
                ? (v) => onToggleActive!(user, v)
                : null,
          ),
          WidgetTableCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isOwner && onEdit != null)
                  IconButton(
                    icon: const Icon(FluentIcons.edit_24_regular, size: 20),
                    onPressed: () => onEdit!(user),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (!isOwner && onDelete != null)
                  IconButton(
                    icon: const Icon(FluentIcons.delete_24_regular, size: 20, color: PUColors.bgError),
                    onPressed: () => onDelete!(user),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ]);
      }).toList(),
      showPagination: totalPages > 1,
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
    );
  }
}
