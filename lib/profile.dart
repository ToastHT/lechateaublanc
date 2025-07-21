import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login.dart';
import 'order_tracking_screen.dart';
import 'personal_data_screen.dart';
import 'settings_screen.dart';
import 'extra_card_screen.dart';
import 'help_center_screen.dart';
import 'account_deletion_screen.dart';
import 'add_account_screen.dart';

class Profile extends StatefulWidget {
  final bool isAdmin;

  const Profile({super.key, required this.isAdmin});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = 'Aspice';
  String userEmail = 'Aspice@gmail.com';
  String userPhone = '+63 912 345 6789';
  String userAddress = 'Imus, Cavite, Philippines';
  String dateOfBirth = '';
  String gender = 'Male';

  List<Map<String, dynamic>> orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistoryList = prefs.getStringList('order_history') ?? [];
    setState(() {
      orderHistory = orderHistoryList
          .map((orderString) => jsonDecode(orderString) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _cancelOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistoryList = prefs.getStringList('order_history') ?? [];

    for (int i = 0; i < orderHistoryList.length; i++) {
      Map<String, dynamic> order = jsonDecode(orderHistoryList[i]);
      if (order['id'] == orderId) {
        order['status'] = 'Cancelled';
        orderHistoryList[i] = jsonEncode(order);
        break;
      }
    }

    await prefs.setStringList('order_history', orderHistoryList);
    _loadOrderHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order cancelled successfully')),
    );
  }

  Future<void> _clearOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('order_history');
    _loadOrderHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order Status cleared successfully')),
    );
  }

  void _showPersonalData() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalDataScreen(
          userName: userName,
          userEmail: userEmail,
          userPhone: userPhone,
          dateOfBirth: dateOfBirth,
          gender: gender,
          onSave: (name, email, phone, dob, genderValue) {
            setState(() {
              userName = name;
              userEmail = email;
              userPhone = phone;
              dateOfBirth = dob;
              gender = genderValue;
            });
          },
        ),
      ),
    );
  }

  void _showOrderHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(
          orders: orderHistory,
          onCancelOrder: _cancelOrder,
          onTrackOrder: _navigateToTracking,
          onClearHistory: _clearOrderHistory,
        ),
      ),
    );
  }

  void _navigateToTracking(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(order: order),
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Do you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            style: TextButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Text(userName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuItem(
                    Icons.person_outline, 'Personal Data', _showPersonalData),
                _buildMenuItem(
                    Icons.history, 'Order Status', _showOrderHistory),
                _buildMenuItem(Icons.settings_outlined, 'Settings', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingsScreen(), // No callback needed!
                    ),
                  );
                }),
                _buildMenuItem(Icons.credit_card_outlined, 'Extra Card', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExtraCardScreen()));
                }),
                _buildMenuItem(Icons.help_outline, 'Help Center', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HelpCenterScreen()));
                }),
                _buildMenuItem(Icons.delete_outline, 'Request Account Deletion',
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountDeletionScreen()));
                }),
                _buildMenuItem(Icons.person_add_outlined, 'Add another account',
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddAccountScreen()));
                }),
                const SizedBox(height: 20),
                InkWell(
                  onTap: _signOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 24),
                        SizedBox(width: 16),
                        Text('Sign Out',
                            style: TextStyle(fontSize: 16, color: Colors.red)),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData iconData, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(iconData, size: 24, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Function(String) onCancelOrder;
  final Function(Map<String, dynamic>) onTrackOrder;
  final Function() onClearHistory;

  const OrderHistoryScreen({
    super.key,
    required this.orders,
    required this.onCancelOrder,
    required this.onTrackOrder,
    required this.onClearHistory,
  });

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'on the way':
        return Colors.green;
      case 'delivered':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _canTrackOrder(String status) {
    return !['delivered', 'cancelled'].contains(status.toLowerCase());
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Order Status'),
        content: const Text(
          'Are you sure you want to clear all order status? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onClearHistory();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _handleOrderTap(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id'].toString().substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${_formatDate(order['orderDate'])}'),
              Text('Status: ${order['status']}'),
              Text('Payment: ${order['paymentMethod']}'),
              const SizedBox(height: 16),
              const Text('Items:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...order['items']
                  .map<Widget>((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    '${item['name']} x${item['quantity']}')),
                            Text(item['price']),
                          ],
                        ),
                      ))
                  .toList(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('₱${order['total'].toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Delivery Address:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(order['deliveryAddress']['name']),
              Text(order['deliveryAddress']['phone']),
              Text(order['deliveryAddress']['address']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_canTrackOrder(order['status']))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onTrackOrder(order);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Track Order'),
            ),
          if (order['status'] != 'Delivered' && order['status'] != 'Cancelled')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Order'),
                    content: const Text(
                        'Are you sure you want to cancel this order?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onCancelOrder(order['id']);
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Yes, Cancel'),
                      ),
                    ],
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel Order'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Status'),
        centerTitle: true,
        actions: [
          if (orders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _showClearHistoryDialog(context),
              tooltip: 'Clear All History',
            ),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No orders yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            )
          : Column(
              children: [
                if (orders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${orders.length} order${orders.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showClearHistoryDialog(context),
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear All'),
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _handleOrderTap(context, order),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Order #${order['id'].toString().substring(0, 8)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                order['status']),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(order['status'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        if (_canTrackOrder(order['status']))
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.track_changes,
                                                  color: Colors.green,
                                                  size: 20),
                                              onPressed: () =>
                                                  onTrackOrder(order),
                                              tooltip: 'Track Order',
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(_formatDate(order['orderDate']),
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 12)),
                                Text(
                                    '${order['items'].length} items • ₱${order['total'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
