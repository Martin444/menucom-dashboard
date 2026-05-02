import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/membership/data/provider/membership_provider.dart';
import 'package:menu_dart_api/by_feature/membership/data/repository/membership_repository.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/get_all_admin_plans_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/create_admin_plan_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/update_admin_plan_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/archive_admin_plan_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/get_admin_plan_stats_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/set_default_plan_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/models/membership_plan_model.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/plan_form_dialog.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/widgets/confirm_archive_dialog.dart';

class MembershipAdminController extends GetxController {
  late final GetAllAdminPlansUseCase getAllPlansUseCase;
  late final CreateAdminPlanUseCase createPlanUseCase;
  late final UpdateAdminPlanUseCase updatePlanUseCase;
  late final ArchiveAdminPlanUseCase archivePlanUseCase;
  late final GetAdminPlanStatsUseCase getStatsUseCase;
  late final SetDefaultPlanUseCase setDefaultPlanUseCase;


  final plans = <MembershipPlanModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  final stats = RxMap<String, dynamic>({});

  MembershipAdminController() {
    final MembershipRepository repo = MembershipProvider();
    getAllPlansUseCase = GetAllAdminPlansUseCase(repository: repo);
    createPlanUseCase = CreateAdminPlanUseCase(repository: repo);
    updatePlanUseCase = UpdateAdminPlanUseCase(repository: repo);
    archivePlanUseCase = ArchiveAdminPlanUseCase(repository: repo);
    getStatsUseCase = GetAdminPlanStatsUseCase(repository: repo);
    setDefaultPlanUseCase = SetDefaultPlanUseCase(repository: repo);
  }

  @override
  void onInit() {
    super.onInit();
    loadPlans();
    loadStats();
  }

  Future<void> loadPlans() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await getAllPlansUseCase.call();
      plans.value = response;
    } catch (e) {
      errorMessage.value = 'Error al cargar planes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await getStatsUseCase.call();
      stats.value = response;
    } catch (e) {
      debugPrint('Error loading membership stats: $e');
    }
  }

  Future<void> createPlan(MembershipPlanModel plan) async {
    isLoading.value = true;
    try {
      await createPlanUseCase.call(plan.toJson());
      GlobalDialogsHandles.snackbarSuccess(
        title: '¡Éxito!',
        message: 'El plan se ha creado correctamente.',
      );
      loadPlans();
      loadStats();
    } catch (e) {
      _showError('Error al crear el plan', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePlan(MembershipPlanModel plan) async {
    if (plan.id == null) return;
    isLoading.value = true;
    try {
      await updatePlanUseCase.call(plan.id!, plan.toJson());
      GlobalDialogsHandles.snackbarSuccess(
        title: '¡Éxito!',
        message: 'El plan se ha actualizado correctamente.',
      );
      loadPlans();
      loadStats();
    } catch (e) {
      _showError('Error al actualizar el plan', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> archivePlan(String planId) async {
    isLoading.value = true;
    try {
      await archivePlanUseCase.call(planId);
      GlobalDialogsHandles.snackbarSuccess(
        title: '¡Éxito!',
        message: 'El plan se ha archivado correctamente.',
      );
      loadPlans();
      loadStats();
    } catch (e) {
      _showError('Error al archivar el plan', e);
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, dynamic e) {
    String rawMessage = e.toString();
    String message = 'Ha ocurrido un error inesperado.';

    try {
      // Intentar extraer el mensaje de un JSON si existe
      if (rawMessage.contains('{')) {
        final start = rawMessage.indexOf('{');
        final end = rawMessage.lastIndexOf('}') + 1;
        final jsonStr = rawMessage.substring(start, end);
        final decoded = json.decode(jsonStr);
        if (decoded is Map && decoded.containsKey('message')) {
          message = decoded['message'];
        }
      } else {
        message = rawMessage;
      }
    } catch (_) {
      message = rawMessage;
    }

    // Traducciones comunes
    if (message.contains("Plan with name") && message.contains("already exists")) {
      final RegExp regExp = RegExp(r"'(.*?)'");
      final match = regExp.firstMatch(message);
      final name = match?.group(1) ?? 'desconocido';
      message = "Ya existe un plan con el nombre '$name'.";
    } else if (message.toLowerCase().contains("unauthorized")) {
      message = "No tienes permisos para realizar esta acción.";
    }

    GlobalDialogsHandles.snackbarError(
      title: title,
      message: message,
    );
  }

  void showCreatePlanDialog() {
    Get.dialog(
      PlanFormDialog(
        onSave: (plan) => createPlan(plan),
      ),
    );
  }

  void showEditPlanDialog(MembershipPlanModel plan) {
    Get.dialog(
      PlanFormDialog(
        plan: plan,
        onSave: (updatedPlan) => updatePlan(updatedPlan),
      ),
    );
  }

  void confirmArchivePlan(MembershipPlanModel plan) {
    if (plan.id == null) return;
    Get.dialog(
      ConfirmArchiveDialog(
        planName: plan.displayName ?? plan.name,
        onConfirm: () => archivePlan(plan.id!),
      ),
    );
  }

  Future<void> setDefaultPlan(MembershipPlanModel plan) async {
    if (plan.id == null) return;
    isLoading.value = true;
    try {
      await setDefaultPlanUseCase.call(plan.id!);
      GlobalDialogsHandles.snackbarSuccess(
        title: '¡Éxito!',
        message: '${plan.displayName ?? plan.name} es ahora el plan predeterminado.',
      );
      loadPlans();
    } catch (e) {
      _showError('Error al establecer plan predeterminado', e);
    } finally {
      isLoading.value = false;
    }
  }
}


