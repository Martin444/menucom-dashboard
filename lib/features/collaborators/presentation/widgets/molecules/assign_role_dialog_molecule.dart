import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:menu_dart_api/by_feature/user_roles/find_user/data/usecase/find_user_usecase.dart';

class AssignRoleDialogMolecule extends StatefulWidget {
  final String? initialEmail;
  final String? initialRole;
  final bool isEditing;

  const AssignRoleDialogMolecule({
    super.key,
    this.initialEmail,
    this.initialRole,
    this.isEditing = false,
  });

  @override
  State<AssignRoleDialogMolecule> createState() =>
      _AssignRoleDialogMoleculeState();
}

class _AssignRoleDialogMoleculeState extends State<AssignRoleDialogMolecule> {
  late final TextEditingController _emailController;
  String _selectedRole = 'operator';
  final _formKey = GlobalKey<FormState>();
  bool _isResolving = false;
  String? _emailError;

  static const _roles = ['manager', 'operator'];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _selectedRole = widget.initialRole ?? 'operator';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'manager':
        return 'Manager';
      case 'operator':
        return 'Operador';
      default:
        return role;
    }
  }

  String _roleDescription(String role) {
    switch (role) {
      case 'manager':
        return 'Gestiona productos y órdenes';
      case 'operator':
        return 'Atención y gestión básica';
      default:
        return '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _emailError = null;
    });

    if (!widget.isEditing) {
      setState(() => _isResolving = true);
      try {
        final findUser = Get.find<FindUserUseCase>();
        final result = await findUser.execute(_emailController.text.trim());
        if (result.userId.isEmpty) {
          setState(() {
            _emailError = 'No se encontró ningún usuario con ese email';
            _isResolving = false;
          });
          return;
        }
        if (!mounted) return;
        Navigator.of(context).pop({
          'userId': result.userId,
          'role': _selectedRole,
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _emailError = 'No se encontró ningún usuario con ese email';
          _isResolving = false;
        });
      }
    } else {
      Navigator.of(context).pop({
        'email': _emailController.text.trim(),
        'role': _selectedRole,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PuDialog(
      title: widget.isEditing ? 'Cambiar rol' : 'Agregar colaborador',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEditing)
              PUInput(
                labelText: 'Email del colaborador',
                hintText: 'email@ejemplo.com',
                controller: _emailController,
                textInputType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresá un email';
                  }
                  if (!v.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
            if (!widget.isEditing && _emailError != null) ...[
              const SizedBox(height: 6),
              Text(
                _emailError!,
                style: const TextStyle(
                  color: PUColors.bgError,
                  fontSize: 12,
                ),
              ),
            ],
            if (!widget.isEditing) const SizedBox(height: 20),
            Text(
              'Rol',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PUColors.textColorRich,
              ),
            ),
            const SizedBox(height: 8),
            ..._roles.map((role) {
              final isSelected = _selectedRole == role;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = role),
                  child: ContainerAtom(
                    variant: ContainerVariant.minimal,
                    borderWidth: isSelected ? 2 : 1,
                    borderColor: isSelected
                        ? PUColors.primaryBlue
                        : PUColors.borderInputColor,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? FluentIcons.radio_button_24_filled
                              : FluentIcons.radio_button_24_regular,
                          size: 20,
                          color: isSelected
                              ? PUColors.primaryBlue
                              : PUColors.textColorMuted,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _roleLabel(role),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _roleDescription(role),
                              style: const TextStyle(
                                fontSize: 12,
                                color: PUColors.textColorMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        ButtonSecundary(
          title: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
          load: false,
        ),
        const SizedBox(width: 12),
        ButtonPrimary(
          title: widget.isEditing ? 'Cambiar rol' : 'Agregar',
          onPressed: _submit,
          load: _isResolving,
        ),
      ],
    );
  }
}
