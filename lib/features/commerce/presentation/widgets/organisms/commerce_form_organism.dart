import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import '../../../../business_selection/models/business_type.dart';
import '../atoms/commerce_logo_picker_atom.dart';
import '../molecules/commerce_type_selector_molecule.dart';
import '../molecules/commerce_info_form_molecule.dart';
import '../molecules/commerce_contact_form_molecule.dart';

class CommerceFormOrganism extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController slugController;
  final TextEditingController descController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final Uint8List? logoBytes;
  final bool isPickingLogo;
  final BusinessType? selectedType;
  final ValueChanged<BusinessType> onSelectType;
  final VoidCallback onSelectLogo;
  final VoidCallback? onSubmit;
  final bool isCreating;
  final GlobalKey<FormState> formKey;
  final int currentStep;
  final VoidCallback onNextStep;
  final VoidCallback onPreviousStep;

  const CommerceFormOrganism({
    super.key,
    required this.nameController,
    required this.slugController,
    required this.descController,
    required this.phoneController,
    required this.addressController,
    this.logoBytes,
    this.isPickingLogo = false,
    this.selectedType,
    required this.onSelectType,
    required this.onSelectLogo,
    this.onSubmit,
    this.isCreating = false,
    required this.formKey,
    required this.currentStep,
    required this.onNextStep,
    required this.onPreviousStep,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = _isWeb(context);
    final stepTitles = ['Información', 'Tipo', 'Contacto'];

    return Column(
      children: [
        // ── Stepper de pasos ──
        _buildStepper(context, stepTitles),
        const SizedBox(height: 8),
        // ── Contenido del paso actual ──
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 32 : 20,
              vertical: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: formKey,
                  child: _buildStepContent(context),
                ),
              ),
            ),
          ),
        ),
        // ── Barra de navegación ──
        _buildNavigationBar(context),
      ],
    );
  }

  bool _isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  Widget _buildStepper(BuildContext context, List<String> stepTitles) {
    final isWeb = _isWeb(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 32 : 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: List.generate(stepTitles.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Línea conectora
            final stepIndex = index ~/ 2;
            final isCompleted = currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: isCompleted
                    ? PUColors.primaryColor
                    : Colors.grey.shade300,
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isActive = currentStep == stepIndex;
          final isCompleted = currentStep > stepIndex;

          return _buildStepDot(
            stepIndex: stepIndex,
            title: stepTitles[stepIndex],
            isActive: isActive,
            isCompleted: isCompleted,
            isWeb: isWeb,
          );
        }),
      ),
    );
  }

  Widget _buildStepDot({
    required int stepIndex,
    required String title,
    required bool isActive,
    required bool isCompleted,
    required bool isWeb,
  }) {
    const Color activeColor = PUColors.primaryColor;
    final Color inactiveColor = Colors.grey.shade300;
    const Color completedColor = PUColors.primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isWeb ? 32 : 28,
          height: isWeb ? 32 : 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? completedColor
                : isActive
                    ? activeColor
                    : inactiveColor,
            border: isActive && !isCompleted
                ? Border.all(color: activeColor.withValues(alpha: 0.3), width: 4)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    FluentIcons.checkmark_24_regular,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive || isCompleted ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                      fontSize: isWeb ? 14 : 12,
                    ),
                  ),
          ),
        ),
        if (isWeb) ...[
          const SizedBox(width: 8),
          Text(
            title,
            style: PuTextStyle.description1.copyWith(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? activeColor
                  : isCompleted
                      ? completedColor
                      : Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final isWeb = _isWeb(context);
    switch (currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3(isWeb);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Información del negocio',
          style: PuTextStyle.title1.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Completá los datos principales de tu comercio',
          style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: CommerceLogoPickerAtom(
            logoBytes: logoBytes,
            isLoading: isPickingLogo,
            onSelectImage: onSelectLogo,
          ),
        ),
        const SizedBox(height: 24),
        CommerceInfoFormMolecule(
          nameController: nameController,
          slugController: slugController,
          descController: descController,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tipo de negocio',
          style: PuTextStyle.title1.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Seleccioná el rubro que mejor describe tu comercio',
          style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CommerceTypeSelectorMolecule(
          selectedType: selectedType,
          onSelectType: onSelectType,
          isCompact: true,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep3(bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Información de contacto',
          style: PuTextStyle.title1.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Datos opcionales para que tus clientes te encuentren',
          style: PuTextStyle.description1.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CommerceContactFormMolecule(
          phoneController: phoneController,
          addressController: addressController,
          isCompact: isWeb,
        ),
        const SizedBox(height: 32),
        ButtonPrimary(
          title: 'Crear negocio',
          onPressed: onSubmit,
          load: isCreating,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    final isWeb = _isWeb(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 32 : 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: ButtonSecundary(
                  title: 'Atrás',
                  onPressed: onPreviousStep,
                  load: false,
                ),
              )
            else
              const Spacer(),
            const SizedBox(width: 12),
            if (currentStep < 2)
              Expanded(
                child: ButtonPrimary(
                  title: 'Siguiente',
                  onPressed: onNextStep,
                  load: false,
                ),
              )
            else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}
