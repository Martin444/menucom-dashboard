import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/events/events.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pickmeup_dashboard/core/analytics_service.dart';

class EventsController extends GetxController {
  final ListEventsUseCase _listEventsUseCase;
  final GetEventByIdUseCase _getEventByIdUseCase;
  final DeleteEventUseCase _deleteEventUseCase;

  EventsController({
    required ListEventsUseCase listEventsUseCase,
    required GetEventByIdUseCase getEventByIdUseCase,
    required DeleteEventUseCase deleteEventUseCase,
  })  : _listEventsUseCase = listEventsUseCase,
        _getEventByIdUseCase = getEventByIdUseCase,
        _deleteEventUseCase = deleteEventUseCase;

  final RxList<EventModel> events = <EventModel>[].obs;
  final Rx<EventModel?> selectedEvent = Rx<EventModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _listEventsUseCase.execute();
      events.assignAll(result);
    } catch (e) {
      debugPrint('Error loading events: $e');
      AnalyticsService().logError(e.toString(), context: 'events_controller.loadEvents');
      errorMessage.value = 'Error al cargar eventos. Intenta de nuevo.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEventDetail(String eventId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final event = await _getEventByIdUseCase.execute(eventId);
      selectedEvent.value = event;
    } catch (e) {
      debugPrint('Error loading event detail: $e');
      AnalyticsService().logError(e.toString(), context: 'events_controller.loadEventDetail');
      errorMessage.value = 'Error al cargar el evento.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    isDeleting.value = true;
    try {
      await _deleteEventUseCase.execute(eventId);
      events.removeWhere((e) => e.id == eventId);
      Get.snackbar(
        'Éxito',
        'Evento eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error deleting event: $e');
      AnalyticsService().logError(e.toString(), context: 'events_controller.deleteEvent');
      Get.snackbar(
        'Error',
        'No se pudo eliminar el evento',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  void navigateToCreateEvent() {
    Get.toNamed(PURoutes.EVENT_CREATE);
  }

  void navigateToEventDetail(String eventId) {
    Get.toNamed(PURoutes.EVENT_DETAIL, arguments: {'eventId': eventId});
  }

  void navigateToEditEvent(String eventId) {
    Get.toNamed(PURoutes.EVENT_EDIT, arguments: {'eventId': eventId});
  }

  void clearSelectedEvent() {
    selectedEvent.value = null;
  }
}
