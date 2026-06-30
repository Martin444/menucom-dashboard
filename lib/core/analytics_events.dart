/// Constantes centralizadas para eventos y parámetros de Firebase Analytics.
///
/// Usar estas constantes en lugar de strings literales evita typos
/// y facilita auditar qué eventos se están rastreando.
abstract class AnalyticsEvents {
  // ── Session ──
  static const String appOpen = 'app_open';
  static const String appBackground = 'app_background';
  static const String appResumed = 'app_resumed';

  // ── Auth (GA4 standard) ──
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String logout = 'logout';

  // ── Catálogos ──
  static const String catalogCreated = 'catalog_created';
  static const String catalogUpdated = 'catalog_updated';
  static const String catalogDeleted = 'catalog_deleted';
  static const String catalogSelected = 'catalog_selected';
  static const String catalogItemCreated = 'catalog_item_created';
  static const String catalogItemUpdated = 'catalog_item_updated';
  static const String catalogItemDeleted = 'catalog_item_deleted';

  // ── Sharing ──
  static const String catalogLinkCopied = 'catalog_link_copied';
  static const String catalogQrGenerated = 'catalog_qr_generated';
  static const String catalogShared = 'catalog_shared';

  // ── Órdenes (GA4 e-commerce) ──
  static const String ordersLoaded = 'orders_loaded';
  static const String orderStatusChanged = 'order_status_changed';

  // ── Perfil ──
  static const String businessProfileSaved = 'business_profile_saved';
  static const String userProfileSaved = 'user_profile_saved';

  // ── Errores ──
  static const String appError = 'app_error';
}

/// Constantes para los parámetros de eventos.
abstract class AnalyticsParams {
  // ── Genéricos ──
  static const String method = 'method';
  static const String name = 'name';
  static const String id = 'id';
  static const String type = 'type';
  static const String context = 'context';
  static const String error = 'error';
  static const String stackTrace = 'stack_trace';
  static const String source = 'source';

  // ── Auth ──
  static const String loginMethod = 'loginMethod';
  static const String signUpMethod = 'signUpMethod';

  // ── Catálogos ──
  static const String catalogId = 'catalog_id';
  static const String catalogName = 'catalog_name';
  static const String price = 'price';
  static const String itemCount = 'item_count';

  // ── Órdenes ──
  static const String orderCount = 'order_count';
  static const String totalRevenue = 'total_revenue';
  static const String status = 'status';
  static const String previousStatus = 'previous_status';

  // ── Perfil ──
  static const String fieldsUpdated = 'fields_updated';

  // ── User Properties ──
  static const String userRole = 'role';
  static const String businessType = 'business_type';
  static const String subscriptionPlan = 'subscription_plan';
  static const String catalogCount = 'catalog_count';
  static const String isEmailVerified = 'is_email_verified';
}
