import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ShoppingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BannerModel>> getBanners() async {
    try {
      final querySnapshot = await _firestore
          .collection('banners')
          .orderBy('order')
          .get();
      
      return querySnapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load banners: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .orderBy('order')
          .get();
      
      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .orderBy('order')
          .get();
      
      return querySnapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<void> toggleProductFavorite(String productId, bool isFavorite) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'isFavorite': isFavorite});
    } catch (e) {
      throw Exception('Failed to update product favorite: $e');
    }
  }

  // Method to seed initial data for testing
  Future<void> seedData() async {
    // Add sample banners
    await _addBanner(
      title: '100 cashback',
      subtitle: 'Shop with 100% cashback',
      imageUrl: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=300&h=200&fit=crop',
      buttonText: 'I want!',
      offer: 'On Shopee',
      order: 1,
    );

    // Add sample categories
    await _addCategory(name: 'Earn 100%', imageUrl: 'https://via.placeholder.com/40x40/E1BEE7/FFFFFF?text=💰', order: 1);
    await _addCategory(name: 'Tax note', imageUrl: 'https://via.placeholder.com/40x40/E1BEE7/FFFFFF?text=📋', order: 2);
    await _addCategory(name: 'Premium', imageUrl: 'https://via.placeholder.com/40x40/E1BEE7/FFFFFF?text=💎', order: 3);
    await _addCategory(name: 'Challenge', imageUrl: 'https://via.placeholder.com/40x40/E1BEE7/FFFFFF?text=🏆', order: 4);
    await _addCategory(name: 'More', imageUrl: 'https://via.placeholder.com/40x40/E1BEE7/FFFFFF?text=⋯', order: 5);

    // Add sample products
    await _addProduct(
      name: 'Monitor LED 4K 28"',
      imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=300&h=200&fit=crop',
      price: 299.99,
      cashbackPercentage: 2.0,
      description: 'High quality 4K monitor',
      order: 1,
    );

    await _addProduct(
      name: 'New balance 480 low',
      imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=200&fit=crop',
      price: 89.99,
      cashbackPercentage: 8.0,
      description: 'Comfortable sports shoes',
      order: 2,
    );
  }

  Future<void> _addBanner({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String buttonText,
    required String offer,
    required int order,
  }) async {
    await _firestore.collection('banners').add({
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'offer': offer,
      'order': order,
    });
  }

  Future<void> _addCategory({
    required String name,
    required String imageUrl,
    required int order,
  }) async {
    await _firestore.collection('categories').add({
      'name': name,
      'imageUrl': imageUrl,
      'order': order,
    });
  }

  Future<void> _addProduct({
    required String name,
    required String imageUrl,
    required double price,
    required double cashbackPercentage,
    required String description,
    required int order,
  }) async {
    await _firestore.collection('products').add({
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'cashbackPercentage': cashbackPercentage,
      'description': description,
      'isFavorite': false,
      'order': order,
    });
  }
} 