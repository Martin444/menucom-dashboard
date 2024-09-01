import 'package:pickmeup_dashboard/features/wardrobes/model/wardrobe_model.dart';

class ClothingItemModel {
  final int id;
  final String name;
  final List<String> sizes;
  final String color;
  final double price;
  final WardrobeModel wardrobe; // Relación con la entidad WardrobeModel

  ClothingItemModel({
    required this.id,
    required this.name,
    required this.sizes,
    required this.color,
    required this.price,
    required this.wardrobe,
  });

  factory ClothingItemModel.fromJson(Map<String, dynamic> json) {
    return ClothingItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sizes: (json['sizes'] as List<dynamic>).cast<String>(),
      color: json['color'] as String,
      price: json['price'] as double,
      wardrobe: WardrobeModel.fromJson(json['wardrobe'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sizes': sizes,
      'color': color,
      'price': price,
      'wardrobe': wardrobe.toJson(),
    };
  }
}
