import 'package:flutter/material.dart';
import 'food_detail.dart';

class CategoryFoods extends StatelessWidget {
  final String categoryName;
  final bool isAdmin;

  const CategoryFoods({
    Key? key,
    required this.categoryName,
    required this.isAdmin,
  }) : super(key: key);

  static const Map<String, List<Map<String, dynamic>>> categoryFoods = {
    'Pizza': [
      {
        'name': 'Margherita Pizza',
        'price': 'P 350.00',
        'rating': '4.8',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Pizza',
        'reviews': '(89)',
        'description': 'Classic margherita with fresh basil and mozzarella',
      },
      {
        'name': 'Pepperoni Pizza',
        'price': 'P 420.00',
        'rating': '4.9',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Pizza',
        'reviews': '(156)',
        'description': 'Loaded with pepperoni and cheese',
      },
      {
        'name': 'Hawaiian Pizza',
        'price': 'P 380.00',
        'rating': '4.6',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Pizza',
        'reviews': '(73)',
        'description': 'Ham and pineapple with cheese',
      },
    ],
    'Burger': [
      {
        'name': 'Classic Burger',
        'price': 'P 159.00',
        'rating': '4.8',
        'image':
            'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Burger',
        'reviews': '(102)',
        'description': 'Classic burger with lettuce and tomato',
      },
      {
        'name': 'Cheese Burger',
        'price': 'P 210.00',
        'rating': '4.6',
        'image':
            'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Burger',
        'reviews': '(94)',
        'description': 'Juicy burger with melted cheese',
      },
      {
        'name': 'Chicken Burger',
        'price': 'P 189.00',
        'rating': '4.7',
        'image':
            'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Burger',
        'reviews': '(67)',
        'description': 'Crispy chicken with special sauce',
      },
    ],
    'Drink': [
      {
        'name': 'Coca Cola',
        'price': 'P 45.00',
        'rating': '4.5',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Coke',
        'reviews': '(234)',
        'description': 'Refreshing cola drink',
      },
      {
        'name': 'Orange Juice',
        'price': 'P 65.00',
        'rating': '4.3',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Juice',
        'reviews': '(89)',
        'description': 'Fresh orange juice',
      },
      {
        'name': 'Iced Tea',
        'price': 'P 55.00',
        'rating': '4.4',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Tea',
        'reviews': '(145)',
        'description': 'Cool and refreshing iced tea',
      },
    ],
    'Dessert': [
      {
        'name': 'Chocolate Cake',
        'price': 'P 120.00',
        'rating': '4.9',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Cake',
        'reviews': '(78)',
        'description': 'Rich chocolate cake with frosting',
      },
      {
        'name': 'Ice Cream',
        'price': 'P 85.00',
        'rating': '4.7',
        'image': 'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Ice',
        'reviews': '(112)',
        'description': 'Vanilla ice cream with toppings',
      },
      {
        'name': 'Cookies',
        'price': 'P 95.00',
        'rating': '4.6',
        'image':
            'https://via.placeholder.com/150x100/FF6B35/FFFFFF?text=Cookie',
        'reviews': '(56)',
        'description': 'Freshly baked chocolate chip cookies',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final foods = categoryFoods[categoryName] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          categoryName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetail(
                    food: food,
                    isAdmin: isAdmin,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    child: Image.network(
                      food['image'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food['price'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${food['rating']} ${food['reviews']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
