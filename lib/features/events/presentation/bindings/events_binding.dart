import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/events/events.dart';

import '../controllers/events_controller.dart';
import '../controllers/event_detail_controller.dart';
import '../controllers/event_wizard_controller.dart';

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.lazyPut<EventProvider>(() => EventProvider());
    Get.lazyPut<VenueProvider>(() => VenueProvider());
    Get.lazyPut<TicketTypeProvider>(() => TicketTypeProvider());

    // Event Use Cases
    Get.lazyPut(() => ListEventsUseCase(Get.find<EventProvider>()));
    Get.lazyPut(() => GetEventByIdUseCase(Get.find<EventProvider>()));
    Get.lazyPut(() => CreateEventUseCase(Get.find<EventProvider>()));
    Get.lazyPut(() => UpdateEventUseCase(Get.find<EventProvider>()));
    Get.lazyPut(() => DeleteEventUseCase(Get.find<EventProvider>()));

    // Venue Use Cases
    Get.lazyPut(() => ListVenuesUseCase(Get.find<VenueProvider>()));
    Get.lazyPut(() => CreateVenueUseCase(Get.find<VenueProvider>()));
    Get.lazyPut(() => GetVenueByIdUseCase(Get.find<VenueProvider>()));
    Get.lazyPut(() => DeleteVenueUseCase(Get.find<VenueProvider>()));

    // Ticket Type Use Cases
    Get.lazyPut(() => CreateTicketTypeUseCase(Get.find<TicketTypeProvider>()));
    Get.lazyPut(() => ListTicketTypesByEventUseCase(Get.find<TicketTypeProvider>()));
    Get.lazyPut(() => UpdateTicketTypeUseCase(Get.find<TicketTypeProvider>()));
    Get.lazyPut(() => DeleteTicketTypeUseCase(Get.find<TicketTypeProvider>()));

    // Controllers
    Get.lazyPut<EventsController>(
      () => EventsController(
        listEventsUseCase: Get.find<ListEventsUseCase>(),
        getEventByIdUseCase: Get.find<GetEventByIdUseCase>(),
        deleteEventUseCase: Get.find<DeleteEventUseCase>(),
      ),
    );

    Get.lazyPut<EventDetailController>(
      () => EventDetailController(
        getEventByIdUseCase: Get.find<GetEventByIdUseCase>(),
        listTicketTypesByEventUseCase: Get.find<ListTicketTypesByEventUseCase>(),
        deleteEventUseCase: Get.find<DeleteEventUseCase>(),
        updateEventUseCase: Get.find<UpdateEventUseCase>(),
        deleteTicketTypeUseCase: Get.find<DeleteTicketTypeUseCase>(),
      ),
    );

    Get.lazyPut<EventWizardController>(
      () => EventWizardController(
        createEventUseCase: Get.find<CreateEventUseCase>(),
        createVenueUseCase: Get.find<CreateVenueUseCase>(),
        listVenuesUseCase: Get.find<ListVenuesUseCase>(),
        createTicketTypeUseCase: Get.find<CreateTicketTypeUseCase>(),
      ),
    );
  }
}
