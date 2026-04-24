import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/by_feature/membership/data/provider/membership_provider.dart';
import 'package:menu_dart_api/by_feature/membership/data/repository/membership_repository.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/get_all_admin_plans_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/create_admin_plan_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/update_admin_plan_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/archive_admin_plan_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/data/usecase/get_admin_plan_stats_usecase.dart';
import 'package:menu_dart_api/by_feature/membership/models/membership_plan_model.dart';

class MembershipAdminController extends GetxController {
  late final GetAllAdminPlansUseCase getAllPlansUseCase;
  late final CreateAdminPlanUseCase createPlanUseCase;
  late final UpdateAdminPlanUseCase updatePlanUseCase;
  late final ArchiveAdminPlanUseCase archivePlanUseCase;
  late final GetAdminPlanStatsUseCase getStatsUseCase;


  final plans = <MembershipPlanModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  final stats = RxMap<String, dynamic>({});

  MembershipAdminController() {
    final MembershipRepository repo = MembershipProvider();
    getAllPlansUseCase = GetAllAdminPlansUseCase(repo);
    createPlanUseCase = CreateAdminPlanUseCase(repo);
    updatePlanUseCase = UpdateAdminPlanUseCase(repo);
    archivePlanUseCase = ArchiveAdminPlanUseCase(repo);
    getStatsUseCase = GetAdminPlanStatsUseCase(repo);
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
      Get.snackbar('Éxito', 'Plan creado correctamente');
      loadPlans();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePlan(MembershipPlanModel plan) async {
    if (plan.id == null) return;
    isLoading.value = true;
    try {
      await updatePlanUseCase.call(plan.id!, plan.toJson());
      Get.snackbar('Éxito', 'Plan actualizado correctamente');
      loadPlans();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> archivePlan(String planId) async {
    isLoading.value = true;
    try {
      await archivePlanUseCase.call(planId);
      Get.snackbar('Éxito', 'Plan archivado correctamente');
      loadPlans();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo archivar el plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showCreatePlanDialog() {
    _showPlanDialog();
  }

  void showEditPlanDialog(MembershipPlanModel plan) {
    _showPlanDialog(plan: plan);
  }

  void _showPlanDialog({MembershipPlanModel? plan}) {
    final nameController = TextEditingController(text: plan?.name);
    final descriptionController = TextEditingController(text: plan?.description);
    final priceController = TextEditingController(text: plan?.price.toString());
    final currencyController = TextEditingController(text: plan?.currency ?? 'ARS');

    Get.dialog(
      AlertDialog(
        title: Text(plan == null ? 'Crear Plan' : 'Editar Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: currencyController,
                decoration: const InputDecoration(labelText: 'Moneda (e.g. ARS, USD)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPlan = MembershipPlanModel(
                id: plan?.id,
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                currency: currencyController.text,
              );
              if (plan == null) {
                createPlan(newPlan);
              } else {
                updatePlan(newPlan);
              }
              Get.back();
            },
            child: Text(plan == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void confirmArchivePlan(MembershipPlanModel plan) {
    if (plan.id == null) return;
    Get.dialog(
      AlertDialog(
        title: const Text('Archivar Plan'),
        content: Text('¿Estás seguro de que deseas archivar el plan "${plan.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              archivePlan(plan.id!);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
  }
}


