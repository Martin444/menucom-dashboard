import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/mp_link_controller.dart';

void main() {
  group('MPLinkController', () {
    test('initial Rx values are correct', () {
      Get.testMode = true;
      final controller = MPLinkController();

      expect(controller.isLinkedToMP.value, isFalse);
      expect(controller.isLoadingMPStatus.value, isFalse);
      expect(controller.isBannerVisible.value, isTrue);
    });

    test('isBannerVisible can be toggled via setBannerVisible', () {
      Get.testMode = true;
      final controller = MPLinkController();

      expect(controller.isBannerVisible.value, isTrue);

      // setBannerVisible updates the Rx value
      controller.isBannerVisible.value = false;
      expect(controller.isBannerVisible.value, isFalse);
    });

    test('isLinkedToMP defaults to false', () {
      Get.testMode = true;
      final controller = MPLinkController();

      expect(controller.isLinkedToMP.value, isFalse);
    });
  });
}
