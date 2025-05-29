import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double cashbackPercentage;
  final String description;
  final bool isFavorite;
  final int order;

  const ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.cashbackPercentage,
    required this.description,
    required this.isFavorite,
    required this.order,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      cashbackPercentage: (data['cashbackPercentage'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'cashbackPercentage': cashbackPercentage,
      'description': description,
      'isFavorite': isFavorite,
      'order': order,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    double? cashbackPercentage,
    String? description,
    bool? isFavorite,
    int? order,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      cashbackPercentage: cashbackPercentage ?? this.cashbackPercentage,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, price, cashbackPercentage, description, isFavorite, order];
} 