import 'package:equatable/equatable.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class ShoppingState extends Equatable {
  const ShoppingState();

  @override
  List<Object> get props => [];
}

class ShoppingInitial extends ShoppingState {}

class ShoppingLoading extends ShoppingState {}

class ShoppingLoaded extends ShoppingState {
  final List<BannerModel> banners;
  final List<CategoryModel> categories;
  final List<ProductModel> products;

  const ShoppingLoaded({
    required this.banners,
    required this.categories,
    required this.products,
  });

  @override
  List<Object> get props => [banners, categories, products];

  ShoppingLoaded copyWith({
    List<BannerModel>? banners,
    List<CategoryModel>? categories,
    List<ProductModel>? products,
  }) {
    return ShoppingLoaded(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      products: products ?? this.products,
    );
  }
}

class ShoppingError extends ShoppingState {
  final String message;

  const ShoppingError(this.message);

  @override
  List<Object> get props => [message];
} 