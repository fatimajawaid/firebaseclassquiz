import 'package:equatable/equatable.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();

  @override
  List<Object> get props => [];
}

class LoadShoppingData extends ShoppingEvent {}

class ToggleProductFavorite extends ShoppingEvent {
  final String productId;
  
  const ToggleProductFavorite(this.productId);
  
  @override
  List<Object> get props => [productId];
} 