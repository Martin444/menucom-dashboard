import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import '../../getx/notifications_controller.dart';
import '../widgets/user_selector.dart';
import '../widgets/template_preview.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        final controller = Get.find<NotificationsController>();
        controller.loadUsers(refresh: true);
        controller.selectedUserIds.clear();
        controller.clearTemplateSelection();
        _initialized = true;
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _urlCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleCtrl.clear();
    _bodyCtrl.clear();
    _urlCtrl.clear();
    _imageUrlCtrl.clear();
  }

  Future<void> _handleSendDirect(NotificationsController controller) async {
    final title = _titleCtrl.text;
    final body = _bodyCtrl.text;
    if (title.trim().isEmpty || body.trim().isEmpty) {
      Get.snackbar('Error', 'El título y el cuerpo son obligatorios');
      return;
    }
    await controller.sendDirect(
      title: title,
      body: body,
      deepLink: _urlCtrl.text,
      imageUrl: _imageUrlCtrl.text,
    );
    _clearForm();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    final isWide = MediaQuery.of(context).size.width > 900;

    return Row(
      children: [
        Expanded(
          flex: isWide ? 3 : 1,
          child: _buildLeftPanel(controller, isWide),
        ),
        if (isWide)
          Expanded(
            flex: 2,
            child: _buildRightPanel(controller),
          ),
      ],
    );
  }

  Widget _buildLeftPanel(NotificationsController controller, bool isWide) {
    return Padding(
      padding: const EdgeInsets.all(PUTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Enviar notificación',
                style: PuTextStyle.title3.copyWith(
                  color: PUColors.textColorRich,
                ),
              ),
              const Spacer(),
              Obx(() {
                return SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Directo'),
                      icon: Icon(FluentIcons.send_24_regular, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Template'),
                      icon: Icon(FluentIcons.document_24_regular, size: 16),
                    ),
                  ],
                  selected: {controller.isDirectMode.value},
                  onSelectionChanged: (v) => controller.setSendMode(v.first),
                  style: SegmentedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 13),
                    selectedBackgroundColor: PUColors.accentColor.withValues(alpha: 0.1),
                    selectedForegroundColor: PUColors.accentColor,
                    foregroundColor: PUColors.textColorMuted,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: PUTokens.xl),
          Expanded(
            child: Obx(() {
              if (controller.isDirectMode.value) {
                return _buildDirectForm(controller, isWide);
              }
              return _buildTemplateForm(controller, isWide);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectForm(NotificationsController controller, bool isWide) {
    return ListView(
      children: [
        if (!isWide) ...[
          _buildMobileUserSection(controller),
          const SizedBox(height: PUTokens.md),
        ],
        PUInput(
          controller: _titleCtrl,
          labelText: 'Título *',
          hintText: '¿Qué vas a comunicar?',
          maxLines: 2,
        ),
        const SizedBox(height: PUTokens.md),
        PUInput(
          controller: _bodyCtrl,
          labelText: 'Cuerpo *',
          hintText: 'Mensaje de la notificación...',
          maxLines: 4,
        ),
        const SizedBox(height: PUTokens.md),
        PUInput(
          controller: _imageUrlCtrl,
          labelText: 'URL de imagen (opcional)',
          hintText: 'https://...',
        ),
        const SizedBox(height: PUTokens.md),
        PUInput(
          controller: _urlCtrl,
          labelText: 'URL de redirección (opcional)',
          hintText: 'https://menucom-dashboard.netlify.app/orden/123',
        ),
        const SizedBox(height: PUTokens.xl),
        SizedBox(
          width: 280,
          child: Obx(() {
            return ButtonPrimary(
              title: 'Enviar notificación',
              icon: FluentIcons.send_24_regular,
              load: controller.isSending.value,
              onPressed: controller.isSending.value
                  ? null
                  : () => _handleSendDirect(controller),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTemplateForm(NotificationsController controller, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWide) ...[
          _buildMobileUserSection(controller),
          const SizedBox(height: PUTokens.md),
        ],
        Row(
          children: [
            Text(
              'Seleccionar template',
              style: PuTextStyle.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: PUColors.textColorRich,
              ),
            ),
            const Spacer(),
            if (controller.selectedTemplateId.value != null)
              TextButton(
                onPressed: () => controller.clearTemplateSelection(),
                child: Text(
                  'Limpiar',
                  style: PuTextStyle.bodySmall.copyWith(
                    color: PUColors.accentColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: PUTokens.sm),
        Expanded(
          child: Obx(() {
            if (controller.selectedTemplateId.value != null) {
              final template = controller.templates.firstWhereOrNull(
                  (t) => t.id == controller.selectedTemplateId.value);
              if (template != null) {
                return SingleChildScrollView(
                  child: TemplatePreview(template: template),
                );
              }
            }

            if (controller.templates.isEmpty) {
              return Center(
                child: Text(
                  'No hay templates disponibles.\nCreá uno primero en la pestaña Templates.',
                  textAlign: TextAlign.center,
                  style: PuTextStyle.bodySmall.copyWith(
                    color: PUColors.textColorLight,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: controller.templates.length,
              itemBuilder: (context, index) {
                final template = controller.templates[index];
                final isSelected =
                    template.id == controller.selectedTemplateId.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: PUTokens.xs),
                  child: ListTile(
                    title: Text(template.name,
                        style: PuTextStyle.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: PUColors.textColorRich,
                        )),
                    subtitle: Text(
                      template.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PuTextStyle.bodySmall,
                    ),
                    leading: Icon(
                      isSelected
                          ? FluentIcons.radio_button_24_filled
                          : FluentIcons.radio_button_24_regular,
                      color: isSelected ? PUColors.accentColor : PUColors.textColorLight,
                    ),
                    selected: isSelected,
                    shape: RoundedRectangleBorder(
                      borderRadius: PUBorderRadius.md,
                    ),
                    onTap: () => controller.selectTemplateForSend(template.id),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: PUTokens.md),
        SizedBox(
          width: 280,
          child: Obx(() {
            final canSend = controller.selectedTemplateId.value != null &&
                (!controller.hasPlaceholders || controller.allPlaceholdersFilled);
            return ButtonPrimary(
              title: 'Enviar desde template',
              icon: FluentIcons.send_24_regular,
              load: controller.isSending.value,
              disabled: !canSend,
              onPressed: (controller.isSending.value || !canSend)
                  ? null
                  : () => controller.sendFromTemplate(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMobileUserSection(NotificationsController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PUColors.borderInputColor),
        borderRadius: PUBorderRadius.lg,
      ),
      child: ExpansionTile(
        title: Obx(() {
          final count = controller.selectedUserIds.length;
          return Text(
            'Destinatarios${count > 0 ? ' ($count)' : ''}',
            style: PuTextStyle.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: PUColors.textColorRich,
            ),
          );
        }),
        children: const [
          SizedBox(
            height: 250,
            child: UserSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(NotificationsController controller) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: PUColors.borderInputColor),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(PUTokens.lg),
        child: UserSelector(),
      ),
    );
  }
}
