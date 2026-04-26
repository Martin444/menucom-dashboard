import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/user/update_user/model/update_user_request.dart';
import 'package:menu_dart_api/by_feature/user/update_user_admin/data/usecase/update_user_admin_usecase.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/dialog_header_atom.dart';

/// Diálogo de edición de usuario.
/// Refactorizado: eliminados _buildHeader y _buildSecuritySection.
class EditUserDialog extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final bool initialNeedToChangePassword;
  final VoidCallback? onSaved;

  const EditUserDialog({
    super.key,
    required this.userId,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialNeedToChangePassword = false,
    this.onSaved,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _needToChangePassword = false;
  bool _isLoading = false;

  final _updateUserUseCase = UpdateUserAdminUseCase();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _emailController.text = widget.initialEmail ?? '';
    _phoneController.text = widget.initialPhone ?? '';
    _needToChangePassword = widget.initialNeedToChangePassword;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shadowColor: PUColors.glassShadow,
      shape: RoundedRectangleBorder(borderRadius: PUBorderRadius.xl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DialogHeaderAtom(
                  title: 'Editar Perfil',
                  subtitle: 'Modifica la información básica del usuario',
                  icon: FluentIcons.person_edit_24_regular,
                ),

                Padding(
                  padding: PUSpacing.lg,
                  child: Column(
                    children: [
                      PUInput(
                        controller: _nameController,
                        labelText: 'Nombre Completo',
                        hintText: 'Ej: Juan Pérez',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PUTokens.md),
                      PUInput(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'usuario@ejemplo.com',
                        textInputType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El email es requerido';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Ingrese un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: PUTokens.md),
                      PUInput(
                        controller: _phoneController,
                        labelText: 'Teléfono',
                        hintText: '+54 9 11 1234-5678',
                        textInputType: TextInputType.phone,
                      ),
                      const SizedBox(height: PUTokens.lg),

                      SecuritySectionPanel(
                        needToChangePassword: _needToChangePassword,
                        onChanged: (val) {
                          setState(() => _needToChangePassword = val);
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
                        title: 'Guardar Cambios',
                        onPressed: _isLoading ? null : _handleSave,
                        load: _isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final request = UpdateUserRequest(
          userId: widget.userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          needToChangePassword: _needToChangePassword,
        );

        final response = await _updateUserUseCase.call(request);

        if (response.success) {
          Get.back();
          GlobalDialogsHandles.snackbarSuccess(
            title: 'Éxito',
            message: 'Usuario actualizado correctamente',
          );
          widget.onSaved?.call();
        } else {
          GlobalDialogsHandles.snackbarError(
            title: 'Error',
            message: response.message,
          );
        }
      } catch (e) {
        GlobalDialogsHandles.snackbarError(
          title: 'Error',
          message: 'Error inesperado: $e',
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Panel de seguridad con switch de cambio de contraseña.
/// Extraído de _buildSecuritySection.
class SecuritySectionPanel extends StatelessWidget {
  final bool needToChangePassword;
  final ValueChanged<bool> onChanged;

  const SecuritySectionPanel({
    super.key,
    required this.needToChangePassword,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PUSpacing.md,
      decoration: BoxDecoration(
        color: PUColors.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PUColors.borderInputColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FluentIcons.shield_keyhole_24_regular,
                  size: 20, color: PUColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Seguridad',
                style: PuTextStyle.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PUColors.textColorRich,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Forzar cambio de contraseña'),
            subtitle: const Text(
                'El usuario deberá renovar su clave al iniciar sesión'),
            value: needToChangePassword,
            activeColor: PUColors.primaryBlue,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}