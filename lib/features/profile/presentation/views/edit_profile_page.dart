import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/organisms/profile_editor_organism.dart';

/// Edit Profile Page - Pantalla para editar perfil de usuario
///
/// Implementa atomic design con organismos, moléculas y átomos
/// para crear una experiencia de edición de perfil completa y consistente.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador
    Get.put(EditProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      builder: (controller) {
        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            // Ctrl+S para guardar
            const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
              if (controller.hasChanges && !controller.isLoading) {
                _saveProfile(controller);
              }
            },
            // Escape para cancelar
            const SingleActivator(LogicalKeyboardKey.escape): () {
              if (controller.hasChanges) {
                _showDiscardChangesDialog(controller);
              } else {
                Get.back();
              }
            },
          },
          child: Focus(
            autofocus: true,
            child: PopScope(
              canPop: !controller.hasChanges,
              onPopInvoked: (didPop) {
                if (!didPop && controller.hasChanges) {
                  _showDiscardChangesDialog(controller);
                }
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: _buildAppBar(controller),
                body: _buildBody(controller),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye la barra de aplicación
  PreferredSizeWidget _buildAppBar(EditProfileController controller) {
    final isWeb = ResponsiveUtils.isWeb(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: isWeb
          ? null
          : IconButton(
              icon: const Icon(
                FluentIcons.arrow_left_24_regular,
                color: Colors.black87,
              ),
              onPressed: () {
                if (controller.hasChanges) {
                  _showDiscardChangesDialog(controller);
                } else {
                  Get.back();
                }
              },
            ),
      automaticallyImplyLeading: !isWeb,
      title: isWeb
          ? null
          : Text(
              'Editar perfil',
              style: PuTextStyle.title3.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
      centerTitle: !isWeb,
      actions: isWeb
          ? null
          : [
              if (controller.hasChanges)
                TextButton(
                  onPressed: controller.isLoading ? null : () => _saveProfile(controller),
                  child: controller.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(PUColors.primaryColor),
                          ),
                        )
                      : Text(
                          'Guardar',
                          style: PuTextStyle.description1.copyWith(
                            color: PUColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
            ],
    );
  }

  /// Construye el cuerpo de la pantalla
  Widget _buildBody(EditProfileController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = ResponsiveUtils.isWeb(context);

        if (isWeb) {
          return _buildWebLayout(controller);
        } else {
          return _buildMobileLayout(controller);
        }
      },
    );
  }

  /// Layout para web (diseño centrado con máximo ancho)
  Widget _buildWebLayout(EditProfileController controller) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final padding = ResponsiveUtils.getAdaptivePadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título para web
              Text(
                'Editar información personal',
                style: PuTextStyle.title2.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              // Indicadores de atajos de teclado para web
              const SizedBox(height: 8),
              _buildKeyboardShortcutsHint(),

              const SizedBox(height: 32),

              // Organismo de edición de perfil
              ProfileEditorOrganism(
                currentImageUrl: controller.currentImageUrl,
                selectedImageBytes: controller.selectedImageBytes,
                onSelectImage: controller.selectImage,
                onRemoveImage: controller.removeSelectedImage,
                nameController: controller.nameController,
                emailController: controller.emailController,
                phoneController: controller.phoneController,
                formKey: _formKey,
              ),

              const SizedBox(height: 48),

              // Botones de acción para web (horizontal)
              _buildWebActionButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye las indicaciones de atajos de teclado
  Widget _buildKeyboardShortcutsHint() {
    return Center(
      child: Wrap(
        spacing: 24,
        children: [
          _buildShortcutHint('Ctrl + S', 'Guardar'),
          _buildShortcutHint('Esc', 'Cancelar'),
        ],
      ),
    );
  }

  /// Construye un hint individual de atajo de teclado
  Widget _buildShortcutHint(String shortcut, String action) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            shortcut,
            style: PuTextStyle.description2.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            action,
            style: PuTextStyle.description2.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Layout para mobile (diseño vertical completo)
  Widget _buildMobileLayout(EditProfileController controller) {
    final padding = ResponsiveUtils.getAdaptivePadding(context);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Organismo de edición de perfil
          ProfileEditorOrganism(
            currentImageUrl: controller.currentImageUrl,
            selectedImageBytes: controller.selectedImageBytes,
            onSelectImage: controller.selectImage,
            onRemoveImage: controller.removeSelectedImage,
            nameController: controller.nameController,
            emailController: controller.emailController,
            phoneController: controller.phoneController,
            formKey: _formKey,
          ),

          const SizedBox(height: 40),

          // Botones de acción para mobile (vertical)
          _buildMobileActionButtons(controller),
        ],
      ),
    );
  }

  /// Construye los botones de acción para web (horizontal)
  Widget _buildWebActionButtons(EditProfileController controller) {
    return Row(
      children: [
        // Botón cancelar (secundario)
        Expanded(
          child: Tooltip(
            message: 'Descartar cambios y volver (Esc)',
            child: ButtonSecundary(
              title: 'Cancelar',
              onPressed: controller.isLoading
                  ? null
                  : () {
                      if (controller.hasChanges) {
                        _showDiscardChangesDialog(controller);
                      } else {
                        Get.back();
                      }
                    },
              load: false,
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Botón guardar (principal)
        Expanded(
          child: Tooltip(
            message: 'Guardar cambios en el perfil (Ctrl+S)',
            child: ButtonPrimary(
              title: 'Guardar cambios',
              onPressed: controller.isLoading ? null : () => _saveProfile(controller),
              load: controller.isLoading,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye los botones de acción para mobile (vertical)
  Widget _buildMobileActionButtons(EditProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón guardar (principal)
        ButtonPrimary(
          title: 'Guardar cambios',
          onPressed: controller.isLoading ? null : () => _saveProfile(controller),
          load: controller.isLoading,
        ),

        const SizedBox(height: 16),

        // Botón cancelar (secundario)
        ButtonSecundary(
          title: 'Cancelar',
          onPressed: controller.isLoading
              ? null
              : () {
                  if (controller.hasChanges) {
                    _showDiscardChangesDialog(controller);
                  } else {
                    Get.back();
                  }
                },
          load: false,
        ),
      ],
    );
  }

  /// Guarda el perfil después de validar
  Future<void> _saveProfile(EditProfileController controller) async {
    if (_formKey.currentState?.validate() ?? false) {
      await controller.saveProfile();
    }
  }

  /// Muestra diálogo para confirmar descarte de cambios
  void _showDiscardChangesDialog(EditProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Descartar cambios',
          style: PuTextStyle.title3,
        ),
        content: Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres salir sin guardarlos?',
          style: PuTextStyle.description1,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: PuTextStyle.description1.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Cerrar diálogo
              controller.resetForm(); // Limpiar cambios
              Get.offAllNamed('/'); // Ir al home y limpiar stack
            },
            child: Text(
              'Descartar',
              style: PuTextStyle.description1.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
