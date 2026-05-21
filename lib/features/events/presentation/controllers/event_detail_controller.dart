import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/events/events.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';

import 'events_controller.dart';

class EventDetailController extends GetxController {
  final GetEventByIdUseCase _getEventByIdUseCase;
  final ListTicketTypesByEventUseCase _listTicketTypesByEventUseCase;
  final DeleteEventUseCase _deleteEventUseCase;
  final UpdateEventUseCase _updateEventUseCase;
  final DeleteTicketTypeUseCase _deleteTicketTypeUseCase;

  EventDetailController({
    required GetEventByIdUseCase getEventByIdUseCase,
    required ListTicketTypesByEventUseCase listTicketTypesByEventUseCase,
    required DeleteEventUseCase deleteEventUseCase,
    required UpdateEventUseCase updateEventUseCase,
    required DeleteTicketTypeUseCase deleteTicketTypeUseCase,
  })  : _getEventByIdUseCase = getEventByIdUseCase,
        _listTicketTypesByEventUseCase = listTicketTypesByEventUseCase,
        _deleteEventUseCase = deleteEventUseCase,
        _updateEventUseCase = updateEventUseCase,
        _deleteTicketTypeUseCase = deleteTicketTypeUseCase;

  final Rx<EventModel?> event = Rx<EventModel?>(null);
  final RxList<TicketTypeModel> ticketTypes = <TicketTypeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxString errorMessage = ''.obs;


  String? get eventId => Get.arguments?['eventId'];

  @override
  void onInit() {
    super.onInit();
    if (eventId != null && eventId!.isNotEmpty) {
      loadEvent();
    } else {
      errorMessage.value = 'ID de evento no válido';
    }
  }

  Future<void> loadEvent() async {
    if (eventId == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final ev = await _getEventByIdUseCase.execute(eventId!);
      event.value = ev;
      if (ev.ticketTypes.isNotEmpty) {
        ticketTypes.assignAll(ev.ticketTypes);
      } else {
        await loadTicketTypes();
      }
    } catch (e) {
      debugPrint('Error loading event: $e');
      errorMessage.value = 'Error al cargar el evento.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTicketTypes() async {
    if (eventId == null) return;
    try {
      final types = await _listTicketTypesByEventUseCase.execute(eventId!);
      ticketTypes.assignAll(types);
    } catch (e) {
      debugPrint('Error loading ticket types: $e');
    }
  }

  Future<void> publishEvent() async {
    if (eventId == null || event.value == null) return;
    isUpdatingStatus.value = true;
    try {
      final params = UpdateEventParams(
        eventId: eventId!,
        status: 'published',
      );
      final updated = await _updateEventUseCase.execute(params);
      event.value = updated;
      event.refresh();
      _syncEventInList(updated);
      Get.snackbar(
        'Éxito',
        'Evento publicado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error publishing event: $e');
      Get.snackbar(
        'Error',
        'No se pudo publicar el evento',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> cancelEvent() async {
    if (eventId == null || event.value == null) return;
    isUpdatingStatus.value = true;
    try {
      final params = UpdateEventParams(
        eventId: eventId!,
        status: 'cancelled',
      );
      final updated = await _updateEventUseCase.execute(params);
      event.value = updated;
      event.refresh();
      _syncEventInList(updated);
      Get.snackbar(
        'Éxito',
        'Evento cancelado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error cancelling event: $e');
      Get.snackbar(
        'Error',
        'No se pudo cancelar el evento',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> deleteEvent() async {
    if (eventId == null) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text('¿Estás seguro de que deseas eliminar este evento? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _deleteEventUseCase.execute(eventId!);
      Get.offAllNamed(PURoutes.EVENTS);
      Get.snackbar(
        'Éxito',
        'Evento eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error deleting event: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar el evento',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteTicketType(String ticketTypeId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Eliminar tipo de ticket'),
        content: const Text('¿Estás seguro de que deseas eliminar este tipo de ticket?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _deleteTicketTypeUseCase.execute(ticketTypeId);
      ticketTypes.removeWhere((t) => t.id == ticketTypeId);
      Get.snackbar(
        'Éxito',
        'Tipo de ticket eliminado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error deleting ticket type: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar el tipo de ticket',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _syncEventInList(EventModel updated) {
    try {
      final eventsController = Get.find<EventsController>();
      final index = eventsController.events.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        eventsController.events[index] = updated;
      }
    } catch (_) {
      // EventsController no está disponible (p.ej. navegación directa)
    }
  }
}
