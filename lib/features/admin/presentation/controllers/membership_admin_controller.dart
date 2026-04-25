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
import 'package:menu_dart_api/by_feature/membership/models/membership_plan_model.dart';
import 'package:pickmeup_dashboard/core/handles/global_handle_dialogs.dart';

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
    getAllPlansUseCase = GetAllAdminPlansUseCase(repository: repo);
    createPlanUseCase = CreateAdminPlanUseCase(repository: repo);
    updatePlanUseCase = UpdateAdminPlanUseCase(repository: repo);
    archivePlanUseCase = ArchiveAdminPlanUseCase(repository: repo);
    getStatsUseCase = GetAdminPlanStatsUseCase(repository: repo);
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
    _showPlanDialog();
  }

  void showEditPlanDialog(MembershipPlanModel plan) {
    _showPlanDialog(plan: plan);
  }

  void _showPlanDialog({MembershipPlanModel? plan}) {
    final nameController = TextEditingController(text: plan?.name);
    final displayNameController = TextEditingController(text: plan?.displayName ?? plan?.name);
    final descriptionController = TextEditingController(text: plan?.description);
    final priceController = TextEditingController(text: plan?.price.toString());
    final currencyController = TextEditingController(text: plan?.currency ?? 'ARS');
    
    // Limits
    final maxCatalogsController = TextEditingController(text: plan?.limits.maxCatalogs.toString() ?? '1');
    final maxCatalogItemsController = TextEditingController(text: plan?.limits.maxCatalogItems.toString() ?? '10');
    final maxLocationsController = TextEditingController(text: plan?.limits.maxLocations.toString() ?? '1');
    final analyticsRetentionController = TextEditingController(text: plan?.limits.analyticsRetention.toString() ?? '7');
    final maxUsersController = TextEditingController(text: plan?.limits.maxUsers.toString() ?? '1');
    final maxApiCallsController = TextEditingController(text: plan?.limits.maxApiCalls.toString() ?? '100');
    final storageLimitController = TextEditingController(text: plan?.limits.storageLimit.toString() ?? '100');
    
    final RxList<TextEditingController> featuresControllers = (plan?.features ?? [])
        .map((f) => TextEditingController(text: f))
        .toList()
        .obs;
        
    if (featuresControllers.isEmpty) {
      featuresControllers.add(TextEditingController());
    }

    Get.dialog(
      AlertDialog(
        title: Text(plan == null ? 'Crear Nuevo Plan' : 'Editar Plan'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información General', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'ID / Nombre Interno', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: displayNameController,
                        decoration: const InputDecoration(labelText: 'Nombre Público', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción del Plan', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: currencyController,
                        decoration: const InputDecoration(labelText: 'Moneda', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Límites del Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSmallTextField(maxCatalogsController, 'Máx. Catálogos'),
                    _buildSmallTextField(maxCatalogItemsController, 'Máx. Ítems/Cat'),
                    _buildSmallTextField(maxLocationsController, 'Máx. Locales'),
                    _buildSmallTextField(analyticsRetentionController, 'Días Analytics'),
                    _buildSmallTextField(maxUsersController, 'Máx. Usuarios'),
                    _buildSmallTextField(maxApiCallsController, 'Llamadas API'),
                    _buildSmallTextField(storageLimitController, 'Storage (MB)'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Características (Features)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      onPressed: () => featuresControllers.add(TextEditingController()),
                    ),
                  ],
                ),
                Obx(() => Column(
                  children: featuresControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'Ej: priority_support',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              if (featuresControllers.length > 1) {
                                featuresControllers.removeAt(index);
                              } else {
                                controller.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                GlobalDialogsHandles.snackbarError(title: 'Campo requerido', message: 'El nombre del plan es obligatorio');
                return;
              }

              final features = featuresControllers
                  .map((c) => c.text.trim())
                  .where((text) => text.isNotEmpty)
                  .toList();

              final limits = MembershipPlanLimits(
                maxCatalogs: int.tryParse(maxCatalogsController.text) ?? 1,
                maxCatalogItems: int.tryParse(maxCatalogItemsController.text) ?? 10,
                maxLocations: int.tryParse(maxLocationsController.text) ?? 1,
                analyticsRetention: int.tryParse(analyticsRetentionController.text) ?? 7,
                maxUsers: int.tryParse(maxUsersController.text) ?? 1,
                maxApiCalls: int.tryParse(maxApiCallsController.text) ?? 100,
                storageLimit: int.tryParse(storageLimitController.text) ?? 100,
              );

              final newPlan = MembershipPlanModel(
                id: plan?.id,
                name: nameController.text.trim(),
                displayName: displayNameController.text.trim(),
                description: descriptionController.text.trim(),
                price: double.tryParse(priceController.text) ?? 0.0,
                currency: currencyController.text.trim().toUpperCase(),
                features: features,
                limits: limits,
                isActive: plan?.isActive ?? true,
              );

              if (plan == null) {
                createPlan(newPlan);
              } else {
                updatePlan(newPlan);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(plan == null ? 'Crear Plan' : 'Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController controller, String label) {
    return SizedBox(
      width: 130,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
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


