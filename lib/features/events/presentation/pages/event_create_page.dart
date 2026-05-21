import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/features/events/ui/templates/event_create_template.dart';
import 'package:pu_material/features/events/models/venue_ui_model.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

import '../controllers/event_wizard_controller.dart';

class EventCreatePage extends StatelessWidget {
  const EventCreatePage({super.key});

  List<VenueUiModel> _mapVenues(EventWizardController controller) {
    return controller.venues.map((v) => VenueUiModel(
      id: v.id,
      name: v.name,
      address: v.address,
      latitude: v.latitude,
      longitude: v.longitude,
      capacity: v.capacity,
      createdAt: v.createdAt,
      updatedAt: v.updatedAt,
    )).toList();
  }

  Future<void> _pickStartDate(BuildContext context, EventWizardController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        controller.startDate.value = DateTime(
          date.year, date.month, date.day, time.hour, time.minute,
        );
        controller.startDateError.value = '';
        if (controller.endDate.value != null &&
            controller.endDate.value!.isAfter(controller.startDate.value!)) {
          controller.endDateError.value = '';
        }
      }
    }
  }

  Future<void> _pickEndDate(BuildContext context, EventWizardController controller) async {
    final initial = controller.startDate.value ?? DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time != null) {
        controller.endDate.value = DateTime(
          date.year, date.month, date.day, time.hour, time.minute,
        );
        controller.endDateError.value = '';
      }
    }
  }

  Future<void> _pickTicketSaleStart(BuildContext context, EventWizardController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        controller.ticketSaleStart.value = DateTime(
          date.year, date.month, date.day, time.hour, time.minute,
        );
        controller.ticketSaleError.value = '';
      }
    }
  }

  Future<void> _pickTicketSaleEnd(BuildContext context, EventWizardController controller) async {
    final initial = controller.ticketSaleStart.value ?? DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time != null) {
        controller.ticketSaleEnd.value = DateTime(
          date.year, date.month, date.day, time.hour, time.minute,
        );
        controller.ticketSaleError.value = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventWizardController>();

    return Obx(() {
      return EventCreateTemplate(
        currentStep: controller.currentStep.value,
        isLoading: controller.isLoading.value,
        errorMessage: controller.errorMessage.value.isEmpty
            ? null
            : controller.errorMessage.value,
        nameController: controller.nameController,
        nameError: controller.nameError.value.isEmpty
            ? null
            : controller.nameError.value,
        descriptionController: controller.descriptionController,
        selectedImage: controller.selectedImage.value,
        onPickImage: controller.pickImage,
        onRemoveImage: controller.removeImage,
        startDate: controller.startDate.value,
        startDateError: controller.startDateError.value.isEmpty
            ? null
            : controller.startDateError.value,
        endDate: controller.endDate.value,
        endDateError: controller.endDateError.value.isEmpty
            ? null
            : controller.endDateError.value,
        onPickStartDate: () => _pickStartDate(context, controller),
        onPickEndDate: () => _pickEndDate(context, controller),
        venues: _mapVenues(controller),
        selectedVenueId: controller.selectedVenueId.value,
        selectedVenueError: controller.selectedVenueError.value.isEmpty
            ? null
            : controller.selectedVenueError.value,
        onSelectVenue: (v) {
          controller.selectedVenueId.value = v;
          controller.selectedVenueError.value = '';
        },
        venueNameController: controller.venueNameController,
        venueAddressController: controller.venueAddressController,
        venueCapacityController: controller.venueCapacityController,
        isCreatingVenue: controller.isCreatingVenue.value,
        onCreateVenue: controller.createVenue,
        ticketTypesDraft: controller.ticketTypesDraft,
        ticketNameController: controller.ticketNameController,
        ticketNameError: controller.ticketNameError.value.isEmpty
            ? null
            : controller.ticketNameError.value,
        ticketPriceController: controller.ticketPriceController,
        ticketPriceError: controller.ticketPriceError.value.isEmpty
            ? null
            : controller.ticketPriceError.value,
        ticketQuantityController: controller.ticketQuantityController,
        ticketQuantityError: controller.ticketQuantityError.value.isEmpty
            ? null
            : controller.ticketQuantityError.value,
        ticketMaxPerUserController: controller.ticketMaxPerUserController,
        ticketSaleStart: controller.ticketSaleStart.value,
        ticketSaleEnd: controller.ticketSaleEnd.value,
        ticketSaleError: controller.ticketSaleError.value.isEmpty
            ? null
            : controller.ticketSaleError.value,
        onPickTicketSaleStart: () => _pickTicketSaleStart(context, controller),
        onPickTicketSaleEnd: () => _pickTicketSaleEnd(context, controller),
        onAddTicketType: controller.addTicketTypeDraft,
        onRemoveTicketType: controller.removeTicketTypeDraft,
        onNextStep: controller.nextStep,
        onPreviousStep: controller.previousStep,
        onSubmit: controller.submit,
        onClose: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.offAllNamed(PURoutes.HOME);
          }
        },
      );
    });
  }
}
