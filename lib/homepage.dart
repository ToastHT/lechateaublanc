import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'search_food.dart';
import 'food_detail.dart';
import 'cart.dart';
import 'message.dart';
import 'profile.dart';
import 'login.dart';
import 'notification.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;

  HomePage({required this.isAdmin});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _notificationCount = 0;
  String _selectedCategory = 'Main Course';
  bool _isLoading = false;

  // Cache for notification count to avoid frequent calculations
  DateTime? _lastNotificationCheck;
  static const Duration _notificationCacheTimeout = Duration(minutes: 1);

  // Updated categories with stylish icons and gradients
  List<Map<String, dynamic>> categories = [
    {
      'name': 'Main Course',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'gradient': LinearGradient(
        colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Appetizers',
      'icon': Icons.local_dining,
      'color': Colors.green,
      'gradient': LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Dessert',
      'icon': Icons.cake,
      'color': Colors.pink,
      'gradient': LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFF06292)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'name': 'Drinks',
      'icon': Icons.local_drink,
      'color': Colors.blue,
      'gradient': LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  // Organized food data with consistent image paths
  Map<String, List<Map<String, dynamic>>> categoryFoods = {
    'Main Course': [
      {
        'name': 'Blanquette de Veau',
        'price': 'P 450.00',
        'rating': '4.8',
        'image': 'assets/images/MainCourse/BlanquettedeVeau.jpg',
        'description': 'Traditional French veal stew in white sauce',
      },
      {
        'name': 'Boeuf Bourguignon',
        'price': 'P 520.00',
        'rating': '4.9',
        'image': 'assets/images/MainCourse/BoeufBourguignon.jpg',
        'description': 'Classic French beef stew braised in red wine',
      },
      {
        'name': 'Bouillabaisse',
        'price': 'P 380.00',
        'rating': '4.7',
        'image': 'assets/images/MainCourse/Bouillabaisse.jpg',
        'description': 'Traditional Provençal fish stew with saffron',
      },
      {
        'name': 'Cassoulet',
        'price': 'P 420.00',
        'rating': '4.6',
        'image': 'assets/images/MainCourse/Cassoulet.jpg',
        'description': 'Rich French bean stew with duck and sausage',
      },
      {
        'name': 'Coq au Vin',
        'price': 'P 380.00',
        'rating': '4.8',
        'image': 'assets/images/MainCourse/CoqauVin.jpg',
        'description': 'Chicken braised in wine with mushrooms',
      },
      {
        'name': 'Duck Orange',
        'price': 'P 480.00',
        'rating': '4.9',
        'image': 'assets/images/MainCourse/DucklOrange.jpg',
        'description': 'Roasted duck breast with orange glaze',
      },
      {
        'name': 'Steak Frites',
        'price': 'P 450.00',
        'rating': '4.7',
        'image': 'assets/images/MainCourse/SteakFrites.jpg',
        'description': 'Grilled steak served with French fries',
      },
      {
        'name': 'Tournedos Rossini',
        'price': 'P 580.00',
        'rating': '4.9',
        'image': 'assets/images/MainCourse/TournedosRossini.jpg',
        'description': 'Beef tenderloin with foie gras and truffle sauce',
      },
    ],
    'Appetizers': [
      {
        'name': 'Escargots de Bourgogne',
        'price': 'P 280.00',
        'rating': '4.7',
        'image': 'assets/images/Apetizers/EscargotsdeBourgogne.jpg',
        'description': 'Classic French snails in garlic butter',
      },
      {
        'name': 'Gougères',
        'price': 'P 150.00',
        'rating': '4.6',
        'image': 'assets/images/Apetizers/Gougères.jpg',
        'description': 'Light and airy cheese puffs',
      },
      {
        'name': 'Pâté de Campagne',
        'price': 'P 220.00',
        'rating': '4.8',
        'image': 'assets/images/Apetizers/patedecampagne.jpg',
        'description': 'Traditional French country pâté',
      },
      {
        'name': 'Quiche Lorraine',
        'price': 'P 180.00',
        'rating': '4.5',
        'image': 'assets/images/Apetizers/QuicheLorraine.jpg',
        'description': 'Classic quiche with bacon and cheese',
      },
      {
        'name': 'Rillettes de Saumon',
        'price': 'P 250.00',
        'rating': '4.9',
        'image': 'assets/images/Apetizers/RillettesdeSaumon.jpg',
        'description': 'Salmon rillettes with fresh herbs',
      },
      {
        'name': 'Salade Niçoise',
        'price': 'P 200.00',
        'rating': '4.6',
        'image': 'assets/images/Apetizers/SaladeNiçoise.jpg',
        'description': 'Traditional Nice salad with tuna and olives',
      },
      {
        'name': 'Soupe à l\'Oignon',
        'price': 'P 160.00',
        'rating': '4.7',
        'image': 'assets/images/Apetizers/SoupeOgnon.jpg',
        'description': 'Classic French onion soup with cheese',
      },
      {
        'name': 'Tartelette aux Champignons',
        'price': 'P 170.00',
        'rating': '4.8',
        'image': 'assets/images/Apetizers/TarteletteauxChampignons.jpg',
        'description': 'Mushroom tart with herbs and cream',
      },
    ],
    'Dessert': [
      {
        'name': 'Blueberry Yogurt Parfait',
        'price': 'P 120.00',
        'rating': '4.8',
        'image': 'assets/images/Dessert/BlueberryYogurtParfait.jpg',
        'description':
            'Layered yogurt parfait with fresh blueberries and granola',
      },
      {
        'name': 'Grilled Pineapple with Coconut Sorbet',
        'price': 'P 160.00',
        'rating': '4.7',
        'image': 'assets/images/Dessert/GrilledPineapplewithCoconutSorbet.jpg',
        'description':
            'Grilled pineapple served with refreshing coconut sorbet',
      },
      {
        'name': 'Lemon Verine',
        'price': 'P 180.00',
        'rating': '4.9',
        'image': 'assets/images/Dessert/LemonVerrine.jpg',
        'description': 'Elegant lemon dessert with layered textures',
      },
      {
        'name': 'Peach Bellini Tart',
        'price': 'P 200.00',
        'rating': '4.8',
        'image': 'assets/images/Dessert/PeachandThymeTartlet.jpg',
        'description': 'Delicate tart with peach bellini flavors',
      },
      {
        'name': 'Strawberry Basil Panna Cotta',
        'price': 'P 170.00',
        'rating': '4.9',
        'image': 'assets/images/Dessert/StrawberryBasilPannaCotta.jpg',
        'description': 'Creamy panna cotta with strawberry and fresh basil',
      },
      {
        'name': 'Watermelon Granita with Mint',
        'price': 'P 140.00',
        'rating': '4.7',
        'image': 'assets/images/Dessert/WatermelonGranitawithMint.jpg',
        'description': 'Refreshing watermelon granita with fresh mint',
      },
    ],
    'Drinks': [
      {
        'name': 'Champagne',
        'price': 'P 350.00',
        'rating': '4.9',
        'image': 'assets/images/Drinks/Champagne.jpg',
        'description': 'Premium French champagne',
      },
      {
        'name': 'Cognac',
        'price': 'P 450.00',
        'rating': '4.8',
        'image': 'assets/images/Drinks/Cognac.jpg',
        'description': 'Fine French cognac',
      },
      {
        'name': 'Kir Royale',
        'price': 'P 180.00',
        'rating': '4.6',
        'image': 'assets/images/Drinks/KirRoyale.jpg',
        'description':
            'Classic French aperitif with champagne and blackcurrant',
      },
      {
        'name': 'Pastis',
        'price': 'P 220.00',
        'rating': '4.4',
        'image': 'assets/images/Drinks/Pastis.jpg',
        'description': 'Traditional French anise-flavored liqueur',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotificationCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotificationCount();
    }
  }

  // Improved notification count loading with caching
  Future<void> _loadNotificationCount() async {
    // Check if we should use cached value
    if (_lastNotificationCheck != null &&
        DateTime.now().difference(_lastNotificationCheck!) <
            _notificationCacheTimeout) {
      return;
    }

    if (_isLoading) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all necessary data at once
      final notificationsList = prefs.getStringList('notifications') ?? [];
      final orderHistoryList = prefs.getStringList('order_history') ?? [];
      final clearedNotifications =
          (prefs.getStringList('cleared_notifications') ?? []).toSet();

      int unreadCount = 0;

      // Count existing unread notifications
      for (String notificationJson in notificationsList) {
        try {
          Map<String, dynamic> notification = jsonDecode(notificationJson);
          if (notification['isRead'] == false &&
              !clearedNotifications.contains(notification['id'])) {
            unreadCount++;
          }
        } catch (e) {
          debugPrint('Error parsing notification: $e');
        }
      }

      // Count pending order notifications
      for (String orderJson in orderHistoryList) {
        try {
          Map<String, dynamic> order = jsonDecode(orderJson);
          String notificationId = 'order_${order['id']}';

          bool notificationExists = notificationsList.any((n) {
            try {
              Map<String, dynamic> notification = jsonDecode(n);
              return notification['id'] == notificationId;
            } catch (e) {
              return false;
            }
          });

          if (!notificationExists &&
              !clearedNotifications.contains(notificationId)) {
            unreadCount++;
          }
        } catch (e) {
          debugPrint('Error parsing order: $e');
        }
      }

      if (mounted) {
        setState(() {
          _notificationCount = unreadCount;
          _lastNotificationCheck = DateTime.now();
        });
      }
    } catch (e) {
      debugPrint('Error loading notification count: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Public method to refresh notification count
  void refreshNotificationCount() {
    _lastNotificationCheck = null; // Force refresh
    _loadNotificationCount();
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == _selectedIndex) return; // Don't navigate if same tab

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Message(isAdmin: widget.isAdmin),
          ),
        ).then((_) => refreshNotificationCount());
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Cart(isAdmin: widget.isAdmin),
          ),
        ).then((_) => refreshNotificationCount());
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(isAdmin: widget.isAdmin),
          ),
        ).then((_) => refreshNotificationCount());
        break;
    }
  }

  void _navigateToFoodDetail(Map<String, dynamic> food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetail(
          food: food,
          isAdmin: widget.isAdmin,
        ),
      ),
    ).then((_) => refreshNotificationCount());
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPage(),
      ),
    ).then((_) => refreshNotificationCount());
  }

  void _onSearchPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchFood(
          categoryFoods: categoryFoods,
          isAdmin: widget.isAdmin,
        ),
      ),
    ).then((_) => refreshNotificationCount());
  }

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildAppBarButton(
            icon: Icons.search,
            onPressed: _onSearchPressed,
          ),
          _buildAppBarButton(
            icon: Icons.notifications,
            onPressed: _navigateToNotifications,
            showBadge: _notificationCount > 0,
            badgeCount: _notificationCount,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadNotificationCount();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCategoriesSection(),
              _buildFoodList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            IconButton(
              icon: Icon(icon, color: Colors.orange),
              onPressed: onPressed,
            ),
            if (showBadge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provide the best',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'food for you',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Find by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category['name'];
              return _buildCategoryItem(category, isSelected);
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
        child: GestureDetector(
          onTap: () => _onCategorySelected(category['name']),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300),
            tween: Tween<double>(
              begin: 0.0,
              end: isSelected ? 1.0 : 0.0,
            ),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.0 + (value * 0.05), // Subtle scale effect
                child: Container(
                  width: 90,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: isSelected ? category['gradient'] : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? category['color'].withOpacity(0.4)
                                  : Colors.grey.withOpacity(0.15),
                              spreadRadius: isSelected ? 3 : 1,
                              blurRadius: isSelected ? 15 : 6,
                              offset: Offset(0, isSelected ? 6 : 2),
                            ),
                            // Add inner glow effect for selected items
                            if (isSelected)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                spreadRadius: -2,
                                blurRadius: 8,
                                offset: Offset(0, 0),
                              ),
                          ],
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                  width: 1.5,
                                ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [0.0, 0.5, 1.0],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.8),
                                      Colors.grey.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          ),
                          child: Stack(
                            children: [
                              // Animated ripple effect
                              if (isSelected)
                                Positioned.fill(
                                  child: TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 1200),
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    builder: (context, rippleValue, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          gradient: RadialGradient(
                                            center: Alignment.center,
                                            radius: rippleValue * 0.8,
                                            colors: [
                                              Colors.white.withOpacity(
                                                  0.3 * (1 - rippleValue)),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              // Main icon with pulse animation
                              Center(
                                child: TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 400),
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: isSelected ? 1.0 : 0.0,
                                  ),
                                  builder: (context, iconValue, child) {
                                    return Transform.scale(
                                      scale: 1.0 + (iconValue * 0.1),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.transparent,
                                        ),
                                        child: Icon(
                                          category['icon'],
                                          size: 36,
                                          color: isSelected
                                              ? Colors.white
                                              : category['color'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Shine effect
                              if (isSelected)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 800),
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    builder: (context, shineValue, child) {
                                      return Opacity(
                                        opacity: (1 - shineValue) * 0.6,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                blurRadius: 4,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isSelected ? 13 : 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color:
                              isSelected ? category['color'] : Colors.black87,
                        ),
                        child: Text(
                          category['name'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    final foods = categoryFoods[_selectedCategory] ?? [];

    if (foods.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No items available in this category',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return _buildFoodItem(food);
      },
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => _navigateToFoodDetail(food),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  food['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Image not found',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    food['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        food['rating'],
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    food['price'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
