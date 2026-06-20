import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config.dart';

class MPLinkController extends GetxController {
  final MPOAuthService _mpService = MPOAuthService();

  RxBool isLinkedToMP = false.obs;
  RxBool isLoadingMPStatus = false.obs;
  RxBool isBannerVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBannerVisibility();
  }

  Future<void> _loadBannerVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    isBannerVisible.value = prefs.getBool('mp_banner_visible') ?? true;
  }

  Future<void> setBannerVisible(bool visible) async {
    isBannerVisible.value = visible;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mp_banner_visible', visible);
  }

  Future<void> checkMPStatus() async {
    try {
      isLoadingMPStatus.value = true;
      final linked = await _mpService.isAccountLinked();
      isLinkedToMP.value = linked;
      debugPrint('MPLinkController: MP Linked Status: $linked');
    } catch (e) {
      debugPrint('Error checking MP status: $e');
    } finally {
      isLoadingMPStatus.value = false;
      update();
    }
  }

  Future<void> vincularMercadoPago() async {
    try {
      final redirectUri = Config.mpRedirectUri;
      final result = await _mpService.initiateLinkingFlow(redirectUri);

      if (result.hasAuthUrl) {
        final uri = Uri.parse(result.authUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'No se pudo abrir el navegador para la vinculación',
            backgroundColor: const Color(0xFFFFEAEA),
            colorText: const Color(0xFFD32F2F),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else if (result.isAlreadyLinked) {
        isLinkedToMP.value = true;
        update();
        Get.snackbar(
          'Aviso',
          'Tu cuenta ya se encuentra vinculada',
          backgroundColor: const Color(0xFFE8F5E9),
          colorText: const Color(0xFF2E7D32),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error initiating MP linking: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado al iniciar la vinculación',
        backgroundColor: const Color(0xFFFFEAEA),
        colorText: const Color(0xFFD32F2F),
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(FluentIcons.error_circle_24_regular, color: Color(0xFFD32F2F)),
      );
    }
  }

  Future<void> refreshMPStatus() async {
    await checkMPStatus();
    if (isLinkedToMP.value) {
      Get.snackbar(
        'Sincronizado',
        'El estado de Mercado Pago se actualizó correctamente',
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(FluentIcons.checkmark_circle_24_regular, color: Color(0xFF2E7D32)),
      );
    }
  }
}
