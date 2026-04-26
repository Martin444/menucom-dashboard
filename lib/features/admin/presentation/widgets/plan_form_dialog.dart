import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/pu_material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:menu_dart_api/by_feature/membership/models/membership_plan_model.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
/// Diálogo para crear o editar un plan de membresía.
/// Extraído de MembershipAdminController para cumplir la separación vista/lógica.
class PlanFormDialog extends StatefulWidget {
  final MembershipPlanModel? plan;
  final Function(MembershipPlanModel plan) onSave;

  const PlanFormDialog({
    super.key,
    this.plan,
    required this.onSave,
  });

  @override
  State<PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends State<PlanFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _maxCatalogsController;
  late final TextEditingController _maxCatalogItemsController;
  late final TextEditingController _maxLocationsController;
  late final TextEditingController _analyticsRetentionController;
  late final TextEditingController _maxUsersController;
  late final TextEditingController _maxApiCallsController;
  late final TextEditingController _storageLimitController;
  final RxList<TextEditingController> _featuresControllers = <TextEditingController>[].obs;

  bool get _isEditing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _nameController = TextEditingController(text: plan?.name);
    _displayNameController = TextEditingController(text: plan?.displayName ?? plan?.name);
    _descriptionController = TextEditingController(text: plan?.description);
    _priceController = TextEditingController(text: plan?.price.toString());
    _currencyController = TextEditingController(text: plan?.currency ?? 'ARS');
    _maxCatalogsController = TextEditingController(text: plan?.limits.maxCatalogs.toString() ?? '1');
    _maxCatalogItemsController = TextEditingController(text: plan?.limits.maxCatalogItems.toString() ?? '10');
    _maxLocationsController = TextEditingController(text: plan?.limits.maxLocations.toString() ?? '1');
    _analyticsRetentionController = TextEditingController(text: plan?.limits.analyticsRetention.toString() ?? '7');
    _maxUsersController = TextEditingController(text: plan?.limits.maxUsers.toString() ?? '1');
    _maxApiCallsController = TextEditingController(text: plan?.limits.maxApiCalls.toString() ?? '100');
    _storageLimitController = TextEditingController(text: plan?.limits.storageLimit.toString() ?? '100');

    _featuresControllers.value = (plan?.features ?? [])
        .map((f) => TextEditingController(text: f))
        .toList();

    if (_featuresControllers.isEmpty) {
      _featuresControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _maxCatalogsController.dispose();
    _maxCatalogItemsController.dispose();
    _maxLocationsController.dispose();
    _analyticsRetentionController.dispose();
    _maxUsersController.dispose();
    _maxApiCallsController.dispose();
    _storageLimitController.dispose();
    for (final c in _featuresControllers) {
      c.dispose();
    }
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
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PUColors.primaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isEditing
                        ? FluentIcons.edit_24_regular
                        : FluentIcons.add_24_regular,
                    color: PUColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: PUTokens.md),
                Expanded(
                  child: TitleAtom(
                    text: _isEditing ? 'Editar Plan' : 'Crear Nuevo Plan',
                    level: TitleLevel.h3,
                  ),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.dismiss_24_regular),
                  onPressed: () => Get.back(),
                  color: PUColors.textColorLight,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información General',
                      style: PuTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PUInput(
                            controller: _nameController,
                            labelText: 'ID / Nombre Interno',
                            hintText: 'ej: premium_monthly',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PUInput(
                            controller: _displayNameController,
                            labelText: 'Nombre Público',
                            hintText: 'ej: Premium Mensual',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PUInput(
                      controller: _descriptionController,
                      labelText: 'Descripción del Plan',
                      hintText: 'Descripción visible para los usuarios',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PUInput(
                            controller: _priceController,
                            labelText: 'Precio',
                            hintText: '0.00',
                            textInputType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PUInput(
                            controller: _currencyController,
                            labelText: 'Moneda',
                            hintText: 'ARS',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Límites del Plan',
                      style: PuTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _PlanLimitField(controller: _maxCatalogsController, label: 'Máx. Catálogos'),
                        _PlanLimitField(controller: _maxCatalogItemsController, label: 'Máx. Ítems/Cat'),
                        _PlanLimitField(controller: _maxLocationsController, label: 'Máx. Locales'),
                        _PlanLimitField(controller: _analyticsRetentionController, label: 'Días Analytics'),
                        _PlanLimitField(controller: _maxUsersController, label: 'Máx. Usuarios'),
                        _PlanLimitField(controller: _maxApiCallsController, label: 'Llamadas API'),
                        _PlanLimitField(controller: _storageLimitController, label: 'Storage (MB)'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Características (Features)',
                          style: PuTextStyle.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(FluentIcons.add_circle_24_regular,
                              color: PUColors.primaryBlue),
                          onPressed: () =>
                              _featuresControllers.add(TextEditingController()),
                        ),
                      ],
                    ),
                    Obx(() => Column(
                          children:
                              _featuresControllers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final controller = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: PUInput(
                                      controller: controller,
                                      hintText: 'Ej: priority_support',
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        FluentIcons.subtract_circle_24_regular,
                                        color: PUColors.errorColor),
                                    onPressed: () {
                                      if (_featuresControllers.length > 1) {
                                        _featuresControllers.removeAt(index);
                                      } else {
                                        controller.clear();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: PUColors.borderInputColor),
            const SizedBox(height: 16),

            // Actions
            Row(
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
                  title: _isEditing ? 'Guardar Cambios' : 'Crear Plan',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (_nameController.text.isEmpty) {
      GlobalDialogsHandles.snackbarError(
        title: 'Campo requerido',
        message: 'El nombre del plan es obligatorio',
      );
      return;
    }

    final features = _featuresControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final limits = MembershipPlanLimits(
      maxCatalogs: int.tryParse(_maxCatalogsController.text) ?? 1,
      maxCatalogItems: int.tryParse(_maxCatalogItemsController.text) ?? 10,
      maxLocations: int.tryParse(_maxLocationsController.text) ?? 1,
      analyticsRetention: int.tryParse(_analyticsRetentionController.text) ?? 7,
      maxUsers: int.tryParse(_maxUsersController.text) ?? 1,
      maxApiCalls: int.tryParse(_maxApiCallsController.text) ?? 100,
      storageLimit: int.tryParse(_storageLimitController.text) ?? 100,
    );

    final newPlan = MembershipPlanModel(
      id: widget.plan?.id,
      name: _nameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      currency: _currencyController.text.trim().toUpperCase(),
      features: features,
      limits: limits,
      isActive: widget.plan?.isActive ?? true,
    );

    widget.onSave(newPlan);
    Get.back();
  }
}

/// Campo numérico compacto para los límites del plan.
class _PlanLimitField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PlanLimitField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: PUInput(
        controller: controller,
        labelText: label,
        textInputType: TextInputType.number,
      ),
    );
  }
}
