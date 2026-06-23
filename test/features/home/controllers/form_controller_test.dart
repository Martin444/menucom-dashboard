import 'package:flutter_test/flutter_test.dart';
import 'package:pickmeup_dashboard/features/home/controllers/form_controller.dart';

void main() {
  group('FormController', () {
    late FormController controller;

    setUp(() {
      controller = FormController();
    });

    test('initial state has empty controllers', () {
      expect(controller.nameController.text, isEmpty);
      expect(controller.priceController.text, isEmpty);
      expect(controller.deliveryController.text, isEmpty);
      expect(controller.photoController, isEmpty);
    });

    test('menusToEdit is null by default', () {
      expect(controller.menusToEdit, isNull);
    });

    test('nameController updates correctly', () {
      controller.nameController.text = 'Test Name';
      expect(controller.nameController.text, 'Test Name');
    });

    test('priceController updates correctly', () {
      controller.priceController.text = '100';
      expect(controller.priceController.text, '100');
    });

    test('deliveryController updates correctly', () {
      controller.deliveryController.text = 'Delivery Info';
      expect(controller.deliveryController.text, 'Delivery Info');
    });

    test('photoController updates correctly', () {
      controller.photoController = 'http://example.com/photo.jpg';
      expect(controller.photoController, 'http://example.com/photo.jpg');
    });

    test('onClose runs without errors', () {
      expect(() => controller.onClose(), returnsNormally);
    });
  });
}
