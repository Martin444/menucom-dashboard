import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickmeup_dashboard/core/helpers/image_size_helper.dart';
import 'package:pickmeup_dashboard/features/commerce/presentation/controllers/create_commerce_controller.dart';
import 'package:pickmeup_dashboard/features/commerce/presentation/widgets/organisms/commerce_form_organism.dart';

class CreateCommercePage extends StatefulWidget {
  const CreateCommercePage({super.key});

  @override
  State<CreateCommercePage> createState() => _CreateCommercePageState();
}

class _CreateCommercePageState extends State<CreateCommercePage> {
  final _formKey = GlobalKey<FormState>();
  late final CreateCommerceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(CreateCommerceController());
  }

  Future<void> _pickImage() async {
    _controller.isPickingLogo.value = true;
    _controller.update();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final resized = ImageSizeHelper.resizeIfNeeded(bytes,
            maxWidth: 512, maxHeight: 512);
        _controller.logoBytes = resized;
      }
    } finally {
      _controller.isPickingLogo.value = false;
      _controller.update();
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.createCommerce();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateCommerceController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                FluentIcons.arrow_left_24_regular,
                color: Colors.black87,
              ),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              'Crear negocio',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: CommerceFormOrganism(
            formKey: _formKey,
            nameController: controller.nameCtrl,
            slugController: controller.slugCtrl,
            descController: controller.descCtrl,
            phoneController: controller.phoneCtrl,
            addressController: controller.addressCtrl,
            logoBytes: controller.logoBytes,
            isPickingLogo: controller.isPickingLogo.value,
            selectedType: controller.selectedType.value,
            onSelectType: controller.selectType,
            onSelectLogo: _pickImage,
            onSubmit: _submit,
            isCreating: controller.isCreating.value,
            currentStep: controller.currentStep.value,
            onNextStep: controller.nextStep,
            onPreviousStep: controller.previousStep,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<CreateCommerceController>()) {
      Get.delete<CreateCommerceController>();
    }
    super.dispose();
  }
}
