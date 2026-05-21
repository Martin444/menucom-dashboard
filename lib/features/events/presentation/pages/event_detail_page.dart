import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/features/events/ui/templates/event_detail_template.dart';
import 'package:pu_material/features/events/models/event_ui_model.dart';
import 'package:pu_material/features/events/models/ticket_type_ui_model.dart';

import '../controllers/event_detail_controller.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  EventUiModel? _mapEvent(EventDetailController controller) {
    final e = controller.event.value;
    if (e == null) return null;
    return EventUiModel(
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
    );
  }

  List<TicketTypeUiModel> _mapTicketTypes(EventDetailController controller) {
    return controller.ticketTypes.map((t) => TicketTypeUiModel(
      id: t.id,
      eventId: t.eventId,
      name: t.name,
      price: t.price,
      totalQuantity: t.totalQuantity,
      soldQuantity: t.soldQuantity,
      saleStartDate: t.saleStartDate,
      saleEndDate: t.saleEndDate,
      maxPerUser: t.maxPerUser,
      status: t.status,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventDetailController>();

    return Obx(() {
      return EventDetailTemplate(
        event: _mapEvent(controller),
        ticketTypes: _mapTicketTypes(controller),
        isLoading: controller.isLoading.value,
        isUpdatingStatus: controller.isUpdatingStatus.value,
        onBack: () => Get.back(),
        onRefresh: controller.loadEvent,
        onPublish: controller.publishEvent,
        onCancel: controller.cancelEvent,
        onDelete: controller.deleteEvent,
        onDeleteTicketType: (t) => controller.deleteTicketType(t.id),
      );
    });
  }
}
