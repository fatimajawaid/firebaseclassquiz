import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/shopping_repository.dart';
import '../models/product_model.dart';
import 'shopping_event.dart';
import 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  final ShoppingRepository _repository;

  ShoppingBloc(this._repository) : super(ShoppingInitial()) {
    on<LoadShoppingData>(_onLoadShoppingData);
    on<ToggleProductFavorite>(_onToggleProductFavorite);
  }

  Future<void> _onLoadShoppingData(
    LoadShoppingData event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(ShoppingLoading());
    
    try {
      final banners = await _repository.getBanners();
      final categories = await _repository.getCategories();
      final products = await _repository.getProducts();
      
      emit(ShoppingLoaded(
        banners: banners,
        categories: categories,
        products: products,
      ));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onToggleProductFavorite(
    ToggleProductFavorite event,
    Emitter<ShoppingState> emit,
  ) async {
    if (state is ShoppingLoaded) {
      final currentState = state as ShoppingLoaded;
      final productIndex = currentState.products.indexWhere(
        (product) => product.id == event.productId,
      );
      
      if (productIndex != -1) {
        final product = currentState.products[productIndex];
        final updatedProduct = product.copyWith(
          isFavorite: !product.isFavorite,
        );
        
        // Update in Firestore
        try {
          await _repository.toggleProductFavorite(
            event.productId,
            updatedProduct.isFavorite,
          );
          
          // Update local state
          final updatedProducts = List<ProductModel>.from(currentState.products);
          updatedProducts[productIndex] = updatedProduct;
          
          emit(currentState.copyWith(products: updatedProducts));
        } catch (e) {
          emit(ShoppingError(e.toString()));
        }
      }
    }
  }
} 