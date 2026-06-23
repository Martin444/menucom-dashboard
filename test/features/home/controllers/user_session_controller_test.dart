import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/user_session_controller.dart';

void main() {
  group('UserSessionController', () {
    test('initial Rx values are correct', () {
      // Must register GetX dependencies first
      Get.testMode = true;
      final controller = UserSessionController();

      expect(controller.isLoadingDataUser.value, isTrue);
      expect(controller.hasErrorLoadingUser.value, isFalse);
      expect(controller.everyListEmpty.value, isTrue);
      expect(controller.hasMissingLogo.value, isFalse);
      expect(controller.hasSelectedCommerce.value, isFalse);
      expect(controller.currentUserRole.value, isEmpty);
    });

    test('isCustomerRole returns false when no role', () {
      Get.testMode = true;
      final controller = UserSessionController();

      expect(controller.isCustomerRole, isFalse);
    });

    test('clearData resets reactive state', () {
      Get.testMode = true;
      final controller = UserSessionController();

      controller.everyListEmpty.value = false;
      controller.hasMissingLogo.value = true;

      controller.clearData();

      expect(controller.everyListEmpty.value, isTrue);
      expect(controller.hasMissingLogo.value, isFalse);
    });
  });
}
