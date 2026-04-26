import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/membership/models/membership_plan_model.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/dialog_header_atom.dart';

/// Diálogo de asignación de membresía.
/// Refactorizado: eliminado _buildHeader, reemplazado por DialogHeaderAtom.
class AssignMembershipDialog extends StatefulWidget {
  final String userName;
  final List<MembershipPlanModel> availablePlans;
  final Function(String planName)? onAssign;

  const AssignMembershipDialog({
    super.key,
    required this.userName,
    required this.availablePlans,
    this.onAssign,
  });

  @override
  State<AssignMembershipDialog> createState() =>
      _AssignMembershipDialogState();
}

class _AssignMembershipDialogState extends State<AssignMembershipDialog> {
  String? _selectedPlan;

  @override
  void initState() {
    super.initState();
    if (widget.availablePlans.isNotEmpty) {
      _selectedPlan = widget.availablePlans.first.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: PUColors.glassShadow,
      shape: RoundedRectangleBorder(borderRadius: PUBorderRadius.xl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeaderAtom(
              title: 'Asignar Plan',
              subtitle: 'Usuario: ${widget.userName}',
              icon: FluentIcons.premium_24_regular,
            ),

            Padding(
              padding: PUSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona un plan para asignar.',
                    style: PuTextStyle.bodyMedium.copyWith(
                      color: PUColors.textColorRich,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta acción otorgará inmediatamente los beneficios del plan seleccionado al usuario.',
                    style: PuTextStyle.bodySmall
                        .copyWith(color: PUColors.textColorLight),
                  ),
                  const SizedBox(height: PUTokens.lg),
                  PUInputDropDown<String>(
                    label: 'Plan de Membresía',
                    hintText: 'Seleccionar plan',
                    errorText: null,
                    items: widget.availablePlans
                        .map((p) {
                          final displayName = p.displayName ?? p.name;
                          return DropdownMenuItem(
                            value: p.name,
                            child: Text(displayName),
                          );
                        })
                        .toList(),
                    initialItem: _selectedPlan,
                    onSelect: (val) {
                      setState(() => _selectedPlan = val);
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: PUColors.borderInputColor),

            Padding(
              padding: PUSpacing.md,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonSecundary(
                    load: false,
                    title: 'Cancelar',
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: PUTokens.sm),
                  ButtonPrimary(
                    load: false,
                    title: 'Confirmar Asignación',
                    onPressed: _selectedPlan != null
                        ? () => widget.onAssign?.call(_selectedPlan!)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
