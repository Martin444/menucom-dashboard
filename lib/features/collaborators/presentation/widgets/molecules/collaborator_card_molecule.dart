import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/user_roles/my_team/model/my_team_response.dart';
import 'package:pu_material/pu_material.dart';
import '../atoms/collaborator_role_badge_atom.dart';

class CollaboratorCardMolecule extends StatelessWidget {
  final TeamUser user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CollaboratorCardMolecule({
    super.key,
    required this.user,
    this.onEdit,
    this.onDelete,
  });

  bool get _isOwner =>
      user.roles.any((r) => r.role.toLowerCase() == 'owner');

  @override
  Widget build(BuildContext context) {
    return ContainerAtom(
      variant: ContainerVariant.card,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          UserAvatarAtom(
            size: 48,
            icon: FluentIcons.person_24_regular,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: PUColors.textColorMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.roles.isNotEmpty) ...[
                  const SizedBox(height: 8),
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
                ],
              ],
            ),
          ),
          if (!_isOwner && (onEdit != null || onDelete != null))
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(FluentIcons.edit_24_regular, size: 20),
                    onPressed: onEdit,
                    color: PUColors.textColorMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(FluentIcons.delete_24_regular, size: 20),
                    onPressed: onDelete,
                    color: PUColors.bgError,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
