import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_dart_api/by_feature/events/events.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

class EventWizardController extends GetxController {
  final CreateEventUseCase _createEventUseCase;
  final CreateVenueUseCase _createVenueUseCase;
  final ListVenuesUseCase _listVenuesUseCase;
  final CreateTicketTypeUseCase _createTicketTypeUseCase;
  final ImagePicker _imagePicker;

  EventWizardController({
    required CreateEventUseCase createEventUseCase,
    required CreateVenueUseCase createVenueUseCase,
    required ListVenuesUseCase listVenuesUseCase,
    required CreateTicketTypeUseCase createTicketTypeUseCase,
    ImagePicker? imagePicker,
  })  : _createEventUseCase = createEventUseCase,
        _createVenueUseCase = createVenueUseCase,
        _listVenuesUseCase = listVenuesUseCase,
        _createTicketTypeUseCase = createTicketTypeUseCase,
        _imagePicker = imagePicker ?? ImagePicker();

  // Step management
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isCreatingVenue = false.obs;

  // Step 1: Event info
  final RxString nameError = ''.obs;
  final RxString startDateError = ''.obs;
  final RxString endDateError = ''.obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Rx<Uint8List?> selectedImage = Rx<Uint8List?>(null);
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Step 2: Venue
  final RxString selectedVenueError = ''.obs;
  final RxList<VenueModel> venues = <VenueModel>[].obs;
  final Rx<String?> selectedVenueId = Rx<String?>(null);
  final TextEditingController venueNameController = TextEditingController();
  final TextEditingController venueAddressController = TextEditingController();
  final TextEditingController venueCapacityController = TextEditingController();

  // Step 3: Ticket types
  final RxString ticketNameError = ''.obs;
  final RxString ticketPriceError = ''.obs;
  final RxString ticketQuantityError = ''.obs;
  final RxString ticketSaleError = ''.obs;
  final RxList<Map<String, dynamic>> ticketTypesDraft = <Map<String, dynamic>>[].obs;
  final TextEditingController ticketNameController = TextEditingController();
  final TextEditingController ticketPriceController = TextEditingController();
  final TextEditingController ticketQuantityController = TextEditingController();
  final TextEditingController ticketMaxPerUserController = TextEditingController(text: '10');
  final Rx<DateTime?> ticketSaleStart = Rx<DateTime?>(null);
  final Rx<DateTime?> ticketSaleEnd = Rx<DateTime?>(null);

  EventModel? createdEvent;

  @override
  void onInit() {
    super.onInit();
    loadVenues();

    nameController.addListener(() {
      if (nameError.isNotEmpty) nameError.value = '';
    });

    ticketNameController.addListener(() {
      if (ticketNameError.isNotEmpty) ticketNameError.value = '';
    });

    ticketPriceController.addListener(() {
      if (ticketPriceError.isNotEmpty) ticketPriceError.value = '';
    });

    ticketQuantityController.addListener(() {
      if (ticketQuantityError.isNotEmpty) ticketQuantityError.value = '';
    });
  }

  Future<void> loadVenues() async {
    try {
      final result = await _listVenuesUseCase.execute();
      venues.assignAll(result);
    } catch (e) {
      debugPrint('Error loading venues: $e');
    }
  }

  bool get canProceedStep1 {
    return nameController.text.trim().length >= 3 &&
        startDate.value != null &&
        endDate.value != null &&
        endDate.value!.isAfter(startDate.value!);
  }

  bool get canProceedStep2 {
    return selectedVenueId.value != null && selectedVenueId.value!.isNotEmpty;
  }

  bool get canSubmit {
    return ticketTypesDraft.isNotEmpty;
  }

  void nextStep() {
    errorMessage.value = '';
    nameError.value = '';
    startDateError.value = '';
    endDateError.value = '';
    selectedVenueError.value = '';

    if (currentStep.value == 0) {
      bool hasError = false;
      final name = nameController.text.trim();
      if (name.isEmpty) {
        nameError.value = 'El nombre es obligatorio.';
        hasError = true;
      } else if (name.length < 3) {
        nameError.value = 'El nombre debe tener al menos 3 caracteres.';
        hasError = true;
      }

      if (startDate.value == null) {
        startDateError.value = 'Seleccioná una fecha de inicio.';
        hasError = true;
      }

      if (endDate.value == null) {
        endDateError.value = 'Seleccioná una fecha de fin.';
        hasError = true;
      } else if (startDate.value != null &&
          !endDate.value!.isAfter(startDate.value!)) {
        endDateError.value =
            'La fecha de fin debe ser posterior a la de inicio.';
        hasError = true;
      }

      if (hasError) {
        errorMessage.value = 'Revisá los campos marcados.';
        return;
      }
    }

    if (currentStep.value == 1) {
      if (selectedVenueId.value == null || selectedVenueId.value!.isEmpty) {
        selectedVenueError.value =
            'Seleccioná o creá un venue para continuar.';
        errorMessage.value = 'Seleccioná o creá un venue.';
        return;
      }
    }

    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      errorMessage.value = '';
      nameError.value = '';
      startDateError.value = '';
      endDateError.value = '';
      selectedVenueError.value = '';
      ticketNameError.value = '';
      ticketPriceError.value = '';
      ticketQuantityError.value = '';
      ticketSaleError.value = '';
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        selectedImage.value = bytes;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar('Error', 'No se pudo cargar la imagen');
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  Future<void> createVenue() async {
    final name = venueNameController.text.trim();
    if (name.length < 2) {
      Get.snackbar('Error', 'El nombre del venue debe tener al menos 2 caracteres');
      return;
    }
    isCreatingVenue.value = true;
    try {
      final capacity = int.tryParse(venueCapacityController.text.trim());
      final params = CreateVenueParams(
        name: name,
        address: venueAddressController.text.trim().isEmpty ? null : venueAddressController.text.trim(),
        capacity: capacity,
      );
      final venue = await _createVenueUseCase.execute(params);
      venues.add(venue);
      selectedVenueId.value = venue.id;
      venueNameController.clear();
      venueAddressController.clear();
      venueCapacityController.clear();
      Get.snackbar('Éxito', 'Venue creado correctamente');
    } catch (e) {
      debugPrint('Error creating venue: $e');
      Get.snackbar('Error', 'No se pudo crear el venue');
    } finally {
      isCreatingVenue.value = false;
    }
  }

  void addTicketTypeDraft() {
    ticketNameError.value = '';
    ticketPriceError.value = '';
    ticketQuantityError.value = '';
    ticketSaleError.value = '';

    final name = ticketNameController.text.trim();
    final price = double.tryParse(ticketPriceController.text.trim()) ?? -1;
    final quantity = int.tryParse(ticketQuantityController.text.trim()) ?? -1;
    final maxPerUser = int.tryParse(ticketMaxPerUserController.text.trim()) ?? 10;

    bool hasError = false;

    if (name.length < 2) {
      ticketNameError.value =
          'El nombre del ticket debe tener al menos 2 caracteres.';
      hasError = true;
    }
    if (price < 0) {
      ticketPriceError.value = 'El precio debe ser 0 o mayor.';
      hasError = true;
    }
    if (quantity <= 0) {
      ticketQuantityError.value = 'La cantidad debe ser mayor a 0.';
      hasError = true;
    }
    if (ticketSaleStart.value == null || ticketSaleEnd.value == null) {
      ticketSaleError.value = 'Seleccioná las fechas de venta.';
      hasError = true;
    }

    if (hasError) {
      errorMessage.value = 'Revisá los campos del ticket.';
      return;
    }

    ticketTypesDraft.add({
      'name': name,
      'price': price,
      'totalQuantity': quantity,
      'maxPerUser': maxPerUser,
      'saleStartDate': ticketSaleStart.value!,
      'saleEndDate': ticketSaleEnd.value!,
    });

    ticketNameController.clear();
    ticketPriceController.clear();
    ticketQuantityController.clear();
    ticketMaxPerUserController.text = '10';
    ticketSaleStart.value = null;
    ticketSaleEnd.value = null;
    errorMessage.value = '';
  }

  void removeTicketTypeDraft(int index) {
    if (index >= 0 && index < ticketTypesDraft.length) {
      ticketTypesDraft.removeAt(index);
    }
  }

  Future<void> submit() async {
    if (!canSubmit) {
      errorMessage.value = 'Agrega al menos un tipo de ticket.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Create event
      final eventParams = CreateEventParams(
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        startDate: startDate.value!,
        endDate: endDate.value!,
        image: selectedImage.value,
        venueId: selectedVenueId.value!,
      );
      createdEvent = await _createEventUseCase.execute(eventParams);

      // 2. Create ticket types
      for (final draft in ticketTypesDraft) {
        final ticketParams = CreateTicketTypeParams(
          eventId: createdEvent!.id,
          name: draft['name'] as String,
          price: draft['price'] as double,
          totalQuantity: draft['totalQuantity'] as int,
          saleStartDate: draft['saleStartDate'] as DateTime,
          saleEndDate: draft['saleEndDate'] as DateTime,
          maxPerUser: draft['maxPerUser'] as int,
        );
        await _createTicketTypeUseCase.execute(ticketParams);
      }

      Get.snackbar(
        'Éxito',
        'Evento creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed(PURoutes.EVENTS);
    } catch (e) {
      debugPrint('Error creating event: $e');
      errorMessage.value = 'Error al crear el evento. Verifica los datos e intenta de nuevo.';
      Get.snackbar(
        'Error',
        'No se pudo crear el evento',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    venueNameController.dispose();
    venueAddressController.dispose();
    venueCapacityController.dispose();
    ticketNameController.dispose();
    ticketPriceController.dispose();
    ticketQuantityController.dispose();
    ticketMaxPerUserController.dispose();
    selectedImage.value = null;
    super.onClose();
  }
}
