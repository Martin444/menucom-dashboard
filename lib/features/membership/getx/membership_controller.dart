import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:url_launcher/url_launcher.dart';

class MembershipController extends GetxController {
  var currentPlan = Rxn<String>();
  var subscriptionStatus = Rxn<String>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isActive = false.obs;
  var amount = 0.0.obs;
  var currency = 'ARS'.obs;
  var nextBillingDate = Rxn<String>();
  var lastPaymentAt = Rxn<String>();
  var hasDiscount = false.obs;
  var discountCode = Rxn<String>();
  var discountPercentage = Rxn<double>();
  var billingHistory = <Map<String, dynamic>>[].obs;
  var plans = <MembershipPlanModel>[].obs;
  var auditHistory = <Map<String, dynamic>>[].obs;

  // ── Use Cases ─────────────────────────────────────────────
  final _getStatusUseCase = GetMembershipStatusUseCase();
  final _getPlansUseCase = GetMembershipPlansUseCase();
  final _createPaymentUseCase = CreateMembershipPaymentUseCase();
  final _subscribeUseCase = SubscribeMembershipUseCase();
  final _applyDiscountUseCase = ApplyMembershipDiscountUseCase();
  final _manageSubscriptionUseCase = ManageMembershipSubscriptionUseCase();
  final _upgradePlanUseCase = UpgradeMembershipPlanUseCase();

  // ── Fetch Status ──────────────────────────────────────────
  Future<void> fetchMembershipStatus() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final status = await _getStatusUseCase.execute();
      _updateFromStatusModel(status);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        isActive.value = false;
        currentPlan.value = 'FREE';
        subscriptionStatus.value = 'inactive';
      } else {
        hasError.value = true;
        errorMessage.value = 'Error: ${e.statusCode} - ${e.message}';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error de conexión: $e';
      debugPrint('Error fetching membership status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateFromStatusModel(MembershipStatusModel status) {
    isActive.value = status.isActive;
    currentPlan.value = status.plan;
    subscriptionStatus.value = status.status;
    amount.value = status.amount;
    currency.value = status.currency;
    nextBillingDate.value = status.nextBillingDate;
    lastPaymentAt.value = status.lastPaymentAt;
    hasDiscount.value = status.hasDiscount;
    discountCode.value = status.discountCode;
    discountPercentage.value = status.discountPercentage;
    billingHistory.value = status.billingHistory;
  }

  // ── Fetch Plans ───────────────────────────────────────────
  Future<void> fetchAvailablePlans() async {
    try {
      isLoading.value = true;
      final result = await _getPlansUseCase.execute();
      plans.value = result;
    } on ApiException catch (e) {
      debugPrint('Error fetching plans: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Subscribe to a Plan ───────────────────────────────────
  /// Para plan FREE: suscribe directamente sin pago.
  /// Para PREMIUM/ENTERPRISE: crea pago y abre MercadoPago.
  Future<bool> subscribeToPlan(String plan) async {
    try {
      isLoading.value = true;

      if (plan.toUpperCase() == 'FREE') {
        // Suscripción directa sin pago
        final status = await _subscribeUseCase.execute(plan);
        _updateFromStatusModel(status);
        return true;
      } else {
        // Crear pago vía MercadoPago y abrir URL
        return await createPayment(plan);
      }
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al suscribirse: $e';
      debugPrint('Error subscribing to plan: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create Payment (MercadoPago) ──────────────────────────
  Future<bool> createPayment(String plan) async {
    try {
      isLoading.value = true;

      final result = await _createPaymentUseCase.execute(plan);
      final redirectUrl = result.redirectUrl;

      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final uri = Uri.parse(redirectUrl);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          hasError.value = true;
          errorMessage.value = 'No se pudo abrir el enlace de pago';
          return false;
        }
        return true;
      }

      hasError.value = true;
      errorMessage.value = 'No se recibió URL de pago';
      return false;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error al crear pago: $e';
      debugPrint('Error creating payment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Apply Discount ────────────────────────────────────────
  Future<bool> applyDiscount(String code) async {
    try {
      isLoading.value = true;

      final result = await _applyDiscountUseCase.execute(code);

      if (result.valid) {
        discountCode.value = code;
        discountPercentage.value = result.percentageOff;
        hasDiscount.value = true;
        return true;
      }

      errorMessage.value = result.message ?? 'Código de descuento inválido';
      return false;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      debugPrint('Error applying discount: $e');
      errorMessage.value = 'Error al aplicar descuento';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Pause Subscription ────────────────────────────────────
  Future<bool> pauseSubscription() async {
    try {
      isLoading.value = true;

      final success = await _manageSubscriptionUseCase.pause();
      if (success) {
        subscriptionStatus.value = 'paused';
        // Refrescar estado completo desde la API
        await fetchMembershipStatus();
      }
      return success;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      debugPrint('Error pausing subscription: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Resume Subscription ───────────────────────────────────
  Future<bool> resumeSubscription() async {
    try {
      isLoading.value = true;

      final success = await _manageSubscriptionUseCase.resume();
      if (success) {
        subscriptionStatus.value = 'authorized';
        // Refrescar estado completo desde la API
        await fetchMembershipStatus();
      }
      return success;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      debugPrint('Error resuming subscription: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Cancel Subscription ───────────────────────────────────
  Future<bool> cancelSubscription() async {
    try {
      isLoading.value = true;

      final success = await _manageSubscriptionUseCase.cancel();
      if (success) {
        isActive.value = false;
        subscriptionStatus.value = 'cancelled';
        // Refrescar estado completo desde la API
        await fetchMembershipStatus();
      }
      return success;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Upgrade Plan ──────────────────────────────────────────
  Future<bool> upgradePlan(String newPlan) async {
    try {
      isLoading.value = true;

      final status = await _upgradePlanUseCase.execute(newPlan);
      _updateFromStatusModel(status);
      return true;
    } on ApiException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      debugPrint('Error upgrading plan: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Subscribe With Card ───────────────────────────────────
  Future<bool> subscribeWithCard(String plan, String cardTokenId,
      {String? discountCode}) async {
    try {
      isLoading.value = true;

      // Este método no tiene UseCase dedicado, reutiliza el provider directamente
      // vía el createPaymentUseCase (que internamente llama al endpoint correcto)
      final result = await createPayment(plan);
      return result;
    } catch (e) {
      debugPrint('Error subscribing with card: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  String formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'authorized':
        return 'Activa';
      case 'paused':
        return 'Pausada';
      case 'pending':
        return 'Pendiente';
      case 'cancelled':
      case 'canceled':
        return 'Cancelada';
      case 'inactive':
        return 'Inactiva';
      default:
        return status ?? 'Desconocido';
    }
  }

  String getPlanLabel(String? plan) {
    switch (plan?.toUpperCase()) {
      case 'FREE':
        return 'Gratis';
      case 'PREMIUM':
        return 'Premium';
      case 'ENTERPRISE':
        return 'Empresarial';
      default:
        return plan ?? 'Gratis';
    }
  }

  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }
}
