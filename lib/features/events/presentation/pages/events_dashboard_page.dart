import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pu_material/features/events/ui/templates/events_dashboard_template.dart';
import 'package:pu_material/features/events/models/event_ui_model.dart';

import '../controllers/events_controller.dart';

class EventsDashboardPage extends StatelessWidget {
  const EventsDashboardPage({super.key});

  List<EventUiModel> _mapEvents(EventsController controller) {
    return controller.events.map((e) => EventUiModel(
      id: e.id,
      name: e.name,
      description: e.description,
      startDate: e.startDate,
      endDate: e.endDate,
      imageUrl: e.imageUrl,
      venueId: e.venueId,
      status: e.status,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventsController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;

        Widget buildBody() {
          return Obx(() {
            final eventsUi = _mapEvents(controller);
            return EventsDashboardTemplate(
              isLoading: controller.isLoading.value,
              errorMessage: controller.errorMessage.value.isEmpty
                  ? null
                  : controller.errorMessage.value,
              events: eventsUi,
              onRetry: controller.loadEvents,
              onCreateEvent: controller.navigateToCreateEvent,
              onEventTap: (event) => controller.navigateToEventDetail(event.id),
              onEventEdit: (event) => controller.navigateToEditEvent(event.id),
              onEventDelete: (event) => controller.deleteEvent(event.id),
            );
          });
        }

        if (isMobile) {
          return Scaffold(
            drawer: const MenuSide(isMobile: true),
            appBar: AppBar(
              title: const Text('Eventos'),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            body: buildBody(),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: isTablet ? 200 : 250,
                child: const MenuSide(isMobile: false),
              ),
              Expanded(child: buildBody()),
            ],
          ),
        );
      },
    );
  }
}


