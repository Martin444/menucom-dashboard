import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';

class FormController extends GetxController {
  CatalogItemModel menusToEdit = CatalogItemModel(
    id: '',
    catalogId: '',
    name: '',
    price: 0.0,
    quantity: 0,
    status: 'available',
    isAvailable: true,
    isFeatured: false,
    displayOrder: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  String photoController = '';

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    deliveryController.dispose();
    super.onClose();
  }
}
