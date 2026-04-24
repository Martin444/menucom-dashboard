import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/views/admin_dashboard_view.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/views/users_view.dart';
import 'package:pickmeup_dashboard/core/navigation/menu_navigation_controller.dart';

class AdminNavItemData {
  final IconData icon;
  final String label;

  const AdminNavItemData({required this.icon, required this.label});
}

class AdminDashboardController extends GetxController {
  final selectedIndex = 0.obs;
  final dashboardData = <String, dynamic>{}.obs;
  final recentOrders = <Map<String, dynamic>>[].obs;

  static const List<Widget> adminViews = [
    AdminDashboardDesktopView(),
    UsersDesktopView(),
  ];

  static const List<AdminNavItemData> navItems = [
    AdminNavItemData(icon: FluentIcons.home_24_regular, label: 'Dashboard'),
    AdminNavItemData(icon: FluentIcons.people_24_regular, label: 'Usuarios'),
  ];

  void onNavIndexChanged(int index) {
    selectedIndex.value = index;
    // Notificar al controlador de navegación para que actualice la selección visual en el sidebar
    try {
      Get.find<MenuNavigationController>().update();
    } catch (_) {}
  }

  Widget get currentView {
    if (selectedIndex.value < adminViews.length) {
      return adminViews[selectedIndex.value];
    }
    return adminViews.first;
  }

  Future<void> loadDashboardData() async {
    dashboardData.value = {
      'totalUsers': 156,
      'totalOrders': 89,
      'revenue': '12,450',
      'activeSessions': 24,
    };

    recentOrders.value = [
      {'id': '#001', 'customer': 'Juan Pérez', 'status': 'completed', 'total': 1500, 'date': '2024-01-15'},
      {'id': '#002', 'customer': 'María García', 'status': 'pending', 'total': 2300, 'date': '2024-01-14'},
      {'id': '#003', 'customer': 'Carlos López', 'status': 'completed', 'total': 850, 'date': '2024-01-14'},
      {'id': '#004', 'customer': 'Ana Martínez', 'status': 'cancelled', 'total': 1200, 'date': '2024-01-13'},
      {'id': '#005', 'customer': 'Pedro Sánchez', 'status': 'pending', 'total': 3200, 'date': '2024-01-12'},
    ];
  }
}