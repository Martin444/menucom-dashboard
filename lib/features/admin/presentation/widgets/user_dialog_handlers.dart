import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/user/get_users_by_roles/model/user_by_role_model.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/user_detail_dialog.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/edit_user_dialog.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/confirm_delete_dialog.dart';

import 'package:pickmeup_dashboard/features/admin/presentation/widgets/assign_membership_dialog.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/billing_details_dialog.dart';
class UserDetailsHandler {
  static void show(UserByRoleModel user) {
    final controller = Get.find<UsersController>();
    
    Get.dialog(
      UserDetailDialog(
        user: user,
        onAssignMembership: () {
          _showAssignMembership(controller, user);
        },
        onBilling: () async {
          final membershipId = user.membership?['id']?.toString() ?? '';
          if (membershipId.isEmpty) {
            Get.snackbar(
              'Error',
              'El usuario no tiene una membresía asignada',
              backgroundColor: Colors.white,
              colorText: PUColors.errorColor,
            );
            return;
          }
          await controller.loadBillingDetails(membershipId);
          Get.dialog(BillingDetailsDialog(user: user));
        },
      ),
    );
  }

  static void _showAssignMembership(UsersController controller, UserByRoleModel user) {
    if (controller.availablePlans.isEmpty) {
      Get.snackbar(
        'Error', 
        'No hay planes disponibles para asignar',
        backgroundColor: Colors.white,
        colorText: PUColors.errorColor,
      );
      return;
    }

    Get.dialog(
      AssignMembershipDialog(
        userName: user.name ?? 'Usuario',
        availablePlans: controller.availablePlans,
        onAssign: (planName) {
          Get.back();
          controller.assignMembership(user.id!, planName);
        },
      ),
    );
  }
}

class UserEditHandler {
  static void show(UserByRoleModel user) {
    final controller = Get.find<UsersController>();
    
    Get.dialog(
      EditUserDialog(
        userId: user.id!,
        initialName: user.name,
        initialEmail: user.email,
        initialPhone: user.phone,
        initialNeedToChangePassword: user.needToChangepassword == true,
        onSaved: () => controller.loadUsers(),
      ),
    );
  }
}

class UserDeleteHandler {
  static void show(UserByRoleModel user) {
    final controller = Get.find<UsersController>();
    
    Get.dialog(
      ConfirmDeleteDialog(
        userName: user.name ?? 'usuario',
        onConfirm: () {
          Get.back();
          controller.deleteUser(user.id!);
        },
      ),
    );
  }
}