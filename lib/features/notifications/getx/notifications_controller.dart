import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';

class NotificationsController extends GetxController {
  final _createUseCase = CreateNotificationTemplateUseCase();
  final _listUseCase = ListNotificationTemplatesUseCase();
  final _getUseCase = GetNotificationTemplateUseCase();
  final _updateUseCase = UpdateNotificationTemplateUseCase();
  final _deleteUseCase = DeleteNotificationTemplateUseCase();
  final _sendDirectUseCase = SendDirectNotificationUseCase();
  final _sendFromTemplateUseCase = SendFromTemplateUseCase();
  final _getUsersUseCase = GetUsersWithFcmTokensUseCase();

  // ---- Templates state ----
  final templates = <NotificationTemplateListItem>[].obs;
  final isTemplatesLoading = false.obs;
  final templatesError = RxnString();
  final templatesPage = 1.obs;
  final templatesHasMore = true.obs;
  final templatesSearch = ''.obs;
  final templatesFilterActive = RxnBool();
  final selectedTabIndex = 0.obs;
  final _templatesMeta = Rxn<NotificationPaginationInfo>();

  int get templatesTotal => _templatesMeta.value?.total ?? 0;
  int get templatesTotalPages => _templatesMeta.value?.totalPages ?? 1;
  int get templatesLimit => _templatesMeta.value?.limit ?? 20;

  // ---- Single template (for create/edit) ----
  final editingTemplate = Rxn<NotificationTemplateModel>();
  final isSaving = false.obs;

  // ---- Send notification state ----
  final isSending = false.obs;

  // ---- Users with FCM ----
  final usersWithFcm = <UserWithFcmToken>[].obs;
  final isUsersLoading = false.obs;
  final usersError = RxnString();
  final usersSearch = ''.obs;
  final usersPage = 1.obs;
  final usersHasMore = true.obs;
  final selectedUserIds = <String>{}.obs;
  final _usersMeta = Rxn<NotificationPaginationInfo>();

  // ---- Send mode ----
  final isDirectMode = true.obs;
  final selectedTemplateId = RxnString();
  final _templatePlaceholders = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  // ==================== TEMPLATES CRUD ====================

  Future<void> loadTemplates({bool refresh = false}) async {
    if (refresh) {
      templatesPage.value = 1;
      templates.clear();
    }

    isTemplatesLoading.value = true;
    templatesError.value = null;

    try {
      final params = ListTemplatesParams(
        page: templatesPage.value,
        limit: 20,
        search: templatesSearch.value.isNotEmpty ? templatesSearch.value : null,
        isActive: templatesFilterActive.value,
      );

      final response = await _listUseCase.call(params);
      templates.addAll(response.data);
      _templatesMeta.value = response.meta;
      templatesHasMore.value =
          response.meta.page < response.meta.totalPages && response.data.isNotEmpty;
    } catch (e) {
      templatesError.value = 'Error al cargar templates: $e';
      debugPrint('Error loading templates: $e');
    } finally {
      isTemplatesLoading.value = false;
    }
  }

  Future<void> loadMoreTemplates() async {
    if (isTemplatesLoading.value || !templatesHasMore.value) return;
    templatesPage.value++;
    await loadTemplates();
  }

  Future<void> searchTemplates(String query) async {
    templatesSearch.value = query;
    await loadTemplates(refresh: true);
  }

  Future<void> filterByActive(bool? isActive) async {
    templatesFilterActive.value = isActive;
    await loadTemplates(refresh: true);
  }

  Future<NotificationTemplateModel?> getTemplate(String id) async {
    try {
      return await _getUseCase.call(id);
    } catch (e) {
      debugPrint('Error getting template: $e');
      Get.snackbar('Error', 'No se pudo cargar el template');
      return null;
    }
  }

  Future<void> loadTemplateForEdit(String id) async {
    editingTemplate.value = null;
    isSaving.value = true;
    try {
      editingTemplate.value = await _getUseCase.call(id);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el template para editar');
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> createTemplate(CreateNotificationTemplateParams params) async {
    isSaving.value = true;
    try {
      await _createUseCase.call(params);
      Get.snackbar('Éxito', 'Template creado correctamente');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el template: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateTemplate(
      String id, UpdateNotificationTemplateParams params) async {
    isSaving.value = true;
    try {
      await _updateUseCase.call(id, params);
      Get.snackbar('Éxito', 'Template actualizado correctamente');
      editingTemplate.value = null;
      return true;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el template: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteTemplate(String id, String name) async {
    final confirm = await Get.defaultDialog<bool>(
      title: 'Desactivar template',
      middleText: '¿Estás seguro de desactivar "$name"?',
      textConfirm: 'Desactivar',
      textCancel: 'Cancelar',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirm != true) return;

    try {
      await _deleteUseCase.call(id);
      Get.snackbar('Éxito', 'Template "$name" desactivado');
      await loadTemplates(refresh: true);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo desactivar el template: $e');
    }
  }

  // ==================== USUARIOS CON FCM ====================

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      usersPage.value = 1;
      usersWithFcm.clear();
    }

    isUsersLoading.value = true;
    usersError.value = null;

    try {
      final params = ListUsersWithTokensParams(
        page: usersPage.value,
        limit: 50,
        search: usersSearch.value.isNotEmpty ? usersSearch.value : null,
      );

      final response = await _getUsersUseCase.call(params);
      usersWithFcm.addAll(response.data);
      _usersMeta.value = response.meta;
      usersHasMore.value =
          response.meta.page < response.meta.totalPages && response.data.isNotEmpty;
    } catch (e) {
      usersError.value = 'Error al cargar usuarios: $e';
      debugPrint('Error loading users: $e');
    } finally {
      isUsersLoading.value = false;
    }
  }

  Future<void> loadMoreUsers() async {
    if (isUsersLoading.value || !usersHasMore.value) return;
    usersPage.value++;
    await loadUsers();
  }

  Future<void> searchUsers(String query) async {
    usersSearch.value = query;
    await loadUsers(refresh: true);
  }

  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
    selectedUserIds.refresh();
  }

  void selectAllUsers() {
    if (selectedUserIds.length == usersWithFcm.length) {
      selectedUserIds.clear();
    } else {
      selectedUserIds
          .addAll(usersWithFcm.map((u) => u.id));
    }
    selectedUserIds.refresh();
  }

  // ==================== ENVÍO DE NOTIFICACIONES ====================

  void setSendMode(bool direct) {
    isDirectMode.value = direct;
    if (direct) {
      selectedTemplateId.value = null;
    }
  }

  void selectTemplateForSend(String templateId) {
    selectedTemplateId.value = templateId;
    _templatePlaceholders.clear();
    final template = templates.firstWhereOrNull((t) => t.id == templateId);
    if (template != null) {
      _extractPlaceholders(template).forEach((p) {
        _templatePlaceholders[p] = '';
      });
      _templatePlaceholders.refresh();
    }
  }

  void clearTemplateSelection() {
    selectedTemplateId.value = null;
    _templatePlaceholders.clear();
  }

  Set<String> _extractPlaceholders(NotificationTemplateListItem template) {
    final combined = '${template.title}\n${template.body}';
    final regex = RegExp(r'\{\{(\w+)\}\}');
    return regex.allMatches(combined).map((m) => m.group(1)!).toSet();
  }

  void updatePlaceholder(String key, String value) {
    _templatePlaceholders[key] = value;
    _templatePlaceholders.refresh();
  }

  Map<String, String> get placeholders => Map.unmodifiable(_templatePlaceholders);

  bool get hasPlaceholders => _templatePlaceholders.isNotEmpty;
  bool get allPlaceholdersFilled =>
      _templatePlaceholders.values.every((v) => v.trim().isNotEmpty);

  Future<SendNotificationResult?> sendDirect({
    required String title,
    required String body,
    String? deepLink,
    String? imageUrl,
  }) async {
    if (selectedUserIds.isEmpty) {
      Get.snackbar('Error', 'Seleccioná al menos un usuario');
      return null;
    }
    if (title.trim().isEmpty || body.trim().isEmpty) {
      Get.snackbar('Error', 'El título y el cuerpo son obligatorios');
      return null;
    }

    isSending.value = true;
    try {
      final trimmedDeepLink = deepLink?.trim();
      final trimmedImageUrl = imageUrl?.trim();
      final params = SendAdminNotificationParams(
        userIds: selectedUserIds.toList(),
        title: title.trim(),
        body: body.trim(),
        deepLink: (trimmedDeepLink != null && trimmedDeepLink.isNotEmpty)
            ? trimmedDeepLink
            : null,
        imageUrl: (trimmedImageUrl != null && trimmedImageUrl.isNotEmpty)
            ? trimmedImageUrl
            : null,
      );

      final result = await _sendDirectUseCase.call(params);
      Get.snackbar(
        'Envío completado',
        'Exitosos: ${result.successCount} | Fallidos: ${result.failureCount}',
      );
      selectedUserIds.clear();
      return result;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo enviar la notificación: $e');
      return null;
    } finally {
      isSending.value = false;
    }
  }

  Future<SendFromTemplateResult?> sendFromTemplate() async {
    if (selectedUserIds.isEmpty) {
      Get.snackbar('Error', 'Seleccioná al menos un usuario');
      return null;
    }
    if (selectedTemplateId.value == null) {
      Get.snackbar('Error', 'Seleccioná un template');
      return null;
    }
    if (hasPlaceholders && !allPlaceholdersFilled) {
      Get.snackbar('Error', 'Completá todos los placeholders');
      return null;
    }

    isSending.value = true;
    try {
      final params = SendFromTemplateParams(
        userIds: selectedUserIds.toList(),
        params: Map.from(_templatePlaceholders),
      );

      final result =
          await _sendFromTemplateUseCase.call(selectedTemplateId.value!, params);
      Get.snackbar(
        'Envío completado',
        'Exitosos: ${result.results.successCount} | Fallidos: ${result.results.failureCount}',
      );
      selectedUserIds.clear();
      selectedTemplateId.value = null;
      _templatePlaceholders.clear();
      return result;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo enviar la notificación: $e');
      return null;
    } finally {
      isSending.value = false;
    }
  }
}
