import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/home/presentation/widget/menu_side.dart';
import 'package:pickmeup_dashboard/features/notifications/getx/notifications_controller.dart';
import 'templates_page.dart';
import 'send_notification_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return const _NotificationsMobileView();
        }
        return const _NotificationsDesktopView();
      },
    );
  }
}

class _NotificationsMobileView extends StatefulWidget {
  const _NotificationsMobileView();

  @override
  State<_NotificationsMobileView> createState() =>
      _NotificationsMobileViewState();
}

class _NotificationsMobileViewState extends State<_NotificationsMobileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<NotificationsController>();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: controller.selectedTabIndex.value,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      drawer: const MenuSide(isMobile: true),
      appBar: AppBar(
        title: Text('Notificaciones', style: PuTextStyle.title3),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(FluentIcons.line_horizontal_3_24_regular),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => controller.selectedTabIndex.value = index,
          labelColor: PUColors.accentColor,
          unselectedLabelColor: PUColors.textColorMuted,
          indicatorColor: PUColors.accentColor,
          tabs: const [
            Tab(
                icon: Icon(FluentIcons.document_24_regular),
                text: 'Templates'),
            Tab(icon: Icon(FluentIcons.send_24_regular), text: 'Enviar'),
          ],
        ),
      ),
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedTabIndex.value,
          children: const [
            TemplatesPage(),
            SendNotificationPage(),
          ],
        );
      }),
    );
  }
}

class _NotificationsDesktopView extends StatefulWidget {
  const _NotificationsDesktopView();

  @override
  State<_NotificationsDesktopView> createState() =>
      _NotificationsDesktopViewState();
}

class _NotificationsDesktopViewState extends State<_NotificationsDesktopView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<NotificationsController>();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: controller.selectedTabIndex.value,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: PUColors.primaryBackground,
      body: Row(
        children: [
          const SizedBox(
            width: 250,
            child: MenuSide(isMobile: false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      Text(
                        'Notificaciones Push',
                        style: PuTextStyle.title2,
                      ),
                      const Spacer(),
                      TabBar(
                        controller: _tabController,
                        onTap: (index) =>
                            controller.selectedTabIndex.value = index,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: PUColors.accentColor,
                        unselectedLabelColor: PUColors.textColorMuted,
                        indicatorColor: PUColors.accentColor,
                        tabs: const [
                          Tab(
                            icon: Icon(FluentIcons.document_24_regular,
                                size: 18),
                            text: 'Templates',
                          ),
                          Tab(
                            icon:
                                Icon(FluentIcons.send_24_regular, size: 18),
                            text: 'Enviar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: PUColors.borderInputColor),
                Expanded(
                  child: Obx(() {
                    return IndexedStack(
                      index: controller.selectedTabIndex.value,
                      children: const [
                        TemplatesPage(),
                        SendNotificationPage(),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
