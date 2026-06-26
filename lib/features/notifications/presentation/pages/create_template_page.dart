import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/notifications/models/notification_template_model.dart';
import 'package:pu_material/pu_material.dart';
import '../../getx/notifications_controller.dart';

class CreateTemplatePage extends StatefulWidget {
  const CreateTemplatePage({super.key});

  @override
  State<CreateTemplatePage> createState() => _CreateTemplatePageState();
}

class _CreateTemplatePageState extends State<CreateTemplatePage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIfEditing();
    });
  }

  void _loadIfEditing() {
    if (_loaded) return;
    final isEdit = Get.arguments is String;
    if (isEdit) {
      final controller = Get.find<NotificationsController>();
      if (controller.editingTemplate.value == null) {
        final templateId = Get.arguments as String;
        controller.loadTemplateForEdit(templateId);
      }
    }
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = Get.arguments is String;
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar template' : 'Nuevo template',
          style: PuTextStyle.title3,
        ),
        leading: IconButton(
          icon: const Icon(FluentIcons.arrow_left_24_regular),
          onPressed: () {
            controller.editingTemplate.value = null;
            Get.back();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isEdit && controller.editingTemplate.value == null
          ? const Center(child: CircularProgressIndicator())
          : const _TemplateForm(),
    );
  }
}

class _TemplateForm extends StatefulWidget {
  const _TemplateForm();

  @override
  State<_TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends State<_TemplateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _deepLinkCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final controller = Get.find<NotificationsController>();
      final template = controller.editingTemplate.value;
      if (template != null) {
        _nameCtrl.text = template.name;
        _titleCtrl.text = template.title;
        _bodyCtrl.text = template.body;
        _deepLinkCtrl.text = template.deepLink ?? '';
        _imageUrlCtrl.text = template.imageUrl ?? '';
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _deepLinkCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    final isEdit = controller.editingTemplate.value != null;
    final template = controller.editingTemplate.value;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(PUTokens.xl, PUTokens.lg, PUTokens.xl, PUTokens.xxl),
        children: [
          PUInput(
            controller: _nameCtrl,
            labelText: 'Nombre interno *',
            hintText: 'Ej: orden_confirmada_v1',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: PUTokens.lg),
          PUInput(
            controller: _titleCtrl,
            labelText: 'Título de la notificación *',
            hintText: 'Tu pedido ha sido confirmado',
            maxLines: 2,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: PUTokens.lg),
          PUInput(
            controller: _bodyCtrl,
            labelText: 'Cuerpo de la notificación *',
            hintText: 'Gracias por tu compra...',
            maxLines: 4,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: PUTokens.lg),
          PUInput(
            controller: _deepLinkCtrl,
            labelText: 'Deep link (opcional)',
            hintText: 'https://menucom-dashboard.netlify.app/orden/123',
          ),
          const SizedBox(height: PUTokens.lg),
          PUInput(
            controller: _imageUrlCtrl,
            labelText: 'URL de imagen (opcional)',
            hintText: 'https://...',
          ),
          const SizedBox(height: PUTokens.lg),
          if (isEdit && template != null) ...[
            const SizedBox(height: PUTokens.xl),
            SwitchListTile(
              title: Text(
                'Template activo',
                style: PuTextStyle.bodyMedium.copyWith(
                  color: PUColors.textColorRich,
                ),
              ),
              value: template.isActive,
              onChanged: (value) {},
              activeColor: PUColors.accentColor,
              secondary: Icon(
                template.isActive
                    ? FluentIcons.checkmark_circle_24_regular
                    : FluentIcons.dismiss_circle_24_regular,
                color: template.isActive ? PUColors.successColor : PUColors.errorColor,
              ),
            ),
          ],
          const SizedBox(height: PUTokens.xl),
          SizedBox(
            width: 280,
            child: Obx(() {
              return ButtonPrimary(
                title: isEdit ? 'Guardar cambios' : 'Crear template',
                icon: isEdit
                    ? FluentIcons.save_24_regular
                    : FluentIcons.add_24_regular,
                load: controller.isSaving.value,
                onPressed: controller.isSaving.value
                    ? null
                    : () => _submit(controller, isEdit, template),
              );
            }),
          ),
          const SizedBox(height: PUTokens.sm),
          SizedBox(
            width: 280,
            height: PUTokens.buttonHeightMd,
            child: OutlinedButton.icon(
              onPressed: () {
                controller.editingTemplate.value = null;
                Get.back();
              },
              icon: const Icon(FluentIcons.dismiss_24_regular, size: 18),
              label: Text(
                'Cancelar',
                style: PuTextStyle.secundaryButtonStyle.copyWith(
                  color: PUColors.primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: PUColors.primaryColor,
                side: const BorderSide(color: PUColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: PUBorderRadius.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(NotificationsController controller, bool isEdit,
      NotificationTemplateModel? template) async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (isEdit && template != null) {
      final params = UpdateNotificationTemplateParams(
        name: _nameCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        deepLink: _deepLinkCtrl.text.trim().isNotEmpty
            ? _deepLinkCtrl.text.trim()
            : null,
        imageUrl: _imageUrlCtrl.text.trim().isNotEmpty
            ? _imageUrlCtrl.text.trim()
            : null,
      );
      success = await controller.updateTemplate(template.id!, params);
    } else {
      final params = CreateNotificationTemplateParams(
        name: _nameCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        deepLink: _deepLinkCtrl.text.trim().isNotEmpty
            ? _deepLinkCtrl.text.trim()
            : null,
        imageUrl: _imageUrlCtrl.text.trim().isNotEmpty
            ? _imageUrlCtrl.text.trim()
            : null,
      );
      success = await controller.createTemplate(params);
    }

    if (success) {
      controller.editingTemplate.value = null;
      Get.back();
    }
  }
}
