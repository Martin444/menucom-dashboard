import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';

class CollaboratorKpiOrganism extends StatelessWidget {
  final int totalCount;
  final int ownerCount;
  final int managerCount;
  final int staffCount;

  const CollaboratorKpiOrganism({
    super.key,
    required this.totalCount,
    required this.ownerCount,
    required this.managerCount,
    required this.staffCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 4,
              child: AdminKpiMolecule(
                title: 'Total',
                value: totalCount.toString(),
                icon: FluentIcons.people_team_24_regular,
                iconColor: PUColors.primaryBlue,
                iconBackground: PUColors.primaryBlueLight,
              ),
            ),
            SizedBox(
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 4,
              child: AdminKpiMolecule(
                title: 'Dueños',
                value: ownerCount.toString(),
                icon: FluentIcons.person_star_24_regular,
                iconColor: const Color(0xFFF59E0B),
                iconBackground: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              ),
            ),
            SizedBox(
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 4,
              child: AdminKpiMolecule(
                title: 'Managers',
                value: managerCount.toString(),
                icon: FluentIcons.person_edit_24_regular,
                iconColor: PUColors.primaryBlue,
                iconBackground: PUColors.primaryBlueLight,
              ),
            ),
            SizedBox(
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 4,
              child: AdminKpiMolecule(
                title: 'Operadores',
                value: staffCount.toString(),
                icon: FluentIcons.person_24_regular,
                iconColor: const Color(0xFF10B981),
                iconBackground: const Color(0xFF10B981).withValues(alpha: 0.1),
              ),
            ),
          ],
        );
      },
    );
  }
}
