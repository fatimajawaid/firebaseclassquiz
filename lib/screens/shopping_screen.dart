import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/shopping_bloc.dart';
import '../bloc/shopping_event.dart';
import '../bloc/shopping_state.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.read<ShoppingBloc>().add(LoadShoppingData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 250, 185, 217), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ShoppingBloc, ShoppingState>(
            builder: (context, state) {
              if (state is ShoppingLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFE91E63)),
                      SizedBox(height: 20),
                      Text('Loading shopping data...'),
                    ],
                  ),
                );
              } else if (state is ShoppingError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 20),
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.read<ShoppingBloc>().add(LoadShoppingData()),
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 10),
                      const Text('Make sure you have seeded the data first!'),
                    ],
                  ),
                );
              }
              
              // Always show the UI (with or without data)
              return _buildShoppingContent(state);
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildShoppingContent(ShoppingState state) {
    List<BannerModel> banners = [];
    List<CategoryModel> categories = [];
    List<ProductModel> products = [];
    
    if (state is ShoppingLoaded) {
      banners = state.banners;
      categories = state.categories;
      products = state.products;
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8), // Top spacing
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildCategoryList(categories),
          const SizedBox(height: 32),
          _buildBannerSlider(banners),
          const SizedBox(height: 32),
          _buildMostPopularSection(products),
          const SizedBox(height: 100), // Bottom spacing for nav
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Profile Picture - Wilson Junior
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Status
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wilson Junior',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Calendar Icon with light grey outline
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF9E9E9E), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF424242),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Notification Icon with light grey outline
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF9E9E9E), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF424242),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Search Field - Transparent outline only
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF9E9E9E), width: 1),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 13, 13, 13),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filter Icon - Transparent outline only
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF9E9E9E), width: 1),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.tune,
              color: Color.fromARGB(255, 15, 14, 14),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    // Default categories with exact icons matching the Figma design
    final List<Map<String, dynamic>> defaultCategories = [
      {'name': 'Earn 100%', 'icon': Icons.percent}, // Percentage icon
      {'name': 'Tax note', 'icon': Icons.description_outlined}, // Document icon
      {'name': 'Premium', 'icon': Icons.diamond_outlined}, // Diamond icon
      {'name': 'Challenge', 'icon': Icons.sports_esports_outlined}, // Gaming controller
      {'name': 'More', 'icon': Icons.more_horiz}, // Three dots
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.isNotEmpty ? categories.length : defaultCategories.length,
        itemBuilder: (context, index) {
          String categoryName;
          IconData categoryIcon;
          
          if (categories.isNotEmpty) {
            categoryName = categories[index].name;
            categoryIcon = _getCategoryIcon(categoryName);
          } else {
            categoryName = defaultCategories[index]['name'];
            categoryIcon = defaultCategories[index]['icon'];
          }
          
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                // Category Icon Circle - Transparent outline only
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF9E9E9E), width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: const Color(0xFF424242),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                // Category Name
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerSlider(List<BannerModel> banners) {
    // Default banner data if no data loaded
    final List<Map<String, dynamic>> defaultBanners = [
      {
        'title': 'Shop with',
        'subtitle': 'cashback',
        'description': 'On Shopee',
        'buttonText': 'I want!',
        'offer': 'Best offer!',
        'image': 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=300&h=200&fit=crop',
      },
      {
        'title': 'Save more with',
        'subtitle': 'deals',
        'description': 'On Amazon',
        'buttonText': 'Shop now!',
        'offer': 'Limited time!',
        'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300&h=200&fit=crop',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "100 cashback" text outside the banner - NOT bold
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            '100 cashback',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF212121),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Banner Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: 170, // Reduced by 16 more pixels to fix overflow (was 126)
            viewportFraction: 0.9,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            enlargeCenterPage: false,
          ),
          items: (banners.isNotEmpty ? banners : defaultBanners.map((b) => BannerModel(
            id: '1',
            title: b['title'],
            subtitle: b['subtitle'],
            imageUrl: b['image'],
            buttonText: b['buttonText'],
            offer: b['offer'],
            order: 1,
          )).toList()).map((banner) {
            final bannerData = banners.isNotEmpty ? {
              'title': banner.title,
              'subtitle': banner.subtitle,
              'description': 'On Shopee',
              'buttonText': banner.buttonText,
              'offer': banner.offer,
              'image': banner.imageUrl,
            } : defaultBanners[0];
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE1BEE7), Color(0xFFCE93D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Headphones Image - Fixed positioning
                  Positioned(
                    right: 10, // Fixed positioning to prevent overflow
                    top: 15,
                    bottom: 15,
                    child: Container(
                      width: 100, // Reduced width to prevent overflow
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(bannerData['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Text Content
                  Positioned(
                    left: 20,
                    top: 20,
                    bottom: 20,
                    right: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${bannerData['title']} ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF212121),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const TextSpan(
                                text: '100%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEC407A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          bannerData['subtitle'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF212121),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          bannerData['description'] ?? 'On Shopee',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Button and "Best offer!" text in a row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC407A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    bannerData['buttonText'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              bannerData['offer'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF424242),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMostPopularSection(List<ProductModel> products) {
    // Default products if no data loaded
    final List<Map<String, dynamic>> defaultProducts = [
      {
        'name': 'Monitor LED 4K 28"',
        'cashback': 2,
        'image': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=300&h=200&fit=crop',
        'isFavorite': false,
      },
      {
        'name': 'New balance 480 low',
        'cashback': 8,
        'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=300&h=200&fit=crop',
        'isFavorite': false,
      },
    ];

    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Most popular offer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212121),
                  letterSpacing: -0.3,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Products List
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.isNotEmpty ? products.length : defaultProducts.length,
            itemBuilder: (context, index) {
              if (products.isNotEmpty) {
                return _buildProductCard(products[index]);
              } else {
                return _buildDefaultProductCard(defaultProducts[index], index);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent, // Completely transparent like in the image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Favorite
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
              // Favorite Icon
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    context.read<ShoppingBloc>().add(
                      ToggleProductFavorite(product.id),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: product.isFavorite ? const Color(0xFFE91E63) : const Color(0xFF9E9E9E),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cashback percentage + icon (bold black) - FIRST
                Row(
                  children: [
                    Text(
                      '${product.cashbackPercentage.toInt()}% cashback',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF000000), // Bold black as shown in image
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.percent,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Product Name (light grey) - SECOND
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E), // Light grey as shown in image
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultProductCard(Map<String, dynamic> product, int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent, // Completely transparent like in the image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Favorite
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: product['image'],
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
              // Favorite Icon
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF9E9E9E),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cashback percentage + icon (bold black) - FIRST
                Row(
                  children: [
                    Text(
                      '${product['cashback']}% cashback',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF000000), // Bold black as shown in image
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.percent,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Product Name (light grey) - SECOND
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E), // Light grey as shown in image
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home, 'Home', true),
          _buildBottomNavItem(Icons.credit_card_outlined, 'Cards', false),
          _buildBottomNavItem(Icons.grid_view_outlined, 'Pix', false),
          _buildBottomNavItem(Icons.note_outlined, 'Notes', false),
          _buildBottomNavItem(Icons.file_download_outlined, 'Extract', false),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF212121) : const Color(0xFF9E9E9E),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFF212121) : const Color(0xFF9E9E9E),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'earn 100%':
        return Icons.percent;
      case 'tax note':
        return Icons.description_outlined;
      case 'premium':
        return Icons.diamond_outlined;
      case 'challenge':
        return Icons.sports_esports_outlined;
      case 'more':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }
} 