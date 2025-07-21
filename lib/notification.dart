import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'profile.dart'; // Import your existing profile.dart
import 'order_tracking_screen.dart'; // Import order tracking screen
import 'settings_service.dart'; // Import settings service

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> orderHistory = [];
  Set<String> clearedNotifications = {}; // Track cleared notifications
  bool isLoading = true;

  // Settings variables
  bool pushNotificationsEnabled = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadData();
  }

  Future<void> _loadSettings() async {
    final push = await SettingsService.getPushNotifications();
    final dark = await SettingsService.getDarkMode();

    setState(() {
      pushNotificationsEnabled = push;
      darkMode = dark;
    });
  }

  Future<void> _loadData() async {
    await _loadClearedNotifications();
    await _loadOrderHistory();
    await _loadNotifications();
    await _generateOrderNotifications();
  }

  Future<void> _loadClearedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cleared = prefs.getStringList('cleared_notifications') ?? [];
    setState(() {
      clearedNotifications = cleared.toSet();
    });
  }

  Future<void> _saveClearedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'cleared_notifications', clearedNotifications.toList());
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

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationsList = prefs.getStringList('notifications') ?? [];

    List<Map<String, dynamic>> loadedNotifications = [];
    for (String notificationJson in notificationsList) {
      try {
        Map<String, dynamic> notification = jsonDecode(notificationJson);
        // Only load if not in cleared list
        if (!clearedNotifications.contains(notification['id'])) {
          loadedNotifications.add(notification);
        }
      } catch (e) {
        print('Error parsing notification: $e');
      }
    }

    setState(() {
      notifications = loadedNotifications;
      isLoading = false;
    });
  }

  Future<void> _generateOrderNotifications() async {
    List<Map<String, dynamic>> orderNotifications = [];

    for (var order in orderHistory) {
      Map<String, dynamic> notification = _createOrderNotification(order);
      String notificationId = notification['id'];

      // Check if notification exists and is not cleared
      bool exists = notifications.any((n) => n['id'] == notificationId);
      bool isCleared = clearedNotifications.contains(notificationId);

      if (!exists && !isCleared) {
        orderNotifications.add(notification);
      }
    }

    if (orderNotifications.isNotEmpty) {
      setState(() {
        notifications.addAll(orderNotifications);
        notifications.sort((a, b) => DateTime.parse(b['timestamp'])
            .compareTo(DateTime.parse(a['timestamp'])));
      });
      await _saveNotifications();
    }
  }

  Map<String, dynamic> _createOrderNotification(Map<String, dynamic> order) {
    String status = order['status'];
    String orderId = order['id'];
    String orderNumber = orderId.substring(0, 8);

    Map<String, dynamic> notification = {
      'id': 'order_$orderId',
      'type': 'order',
      'orderId': orderId,
      'isRead': false,
      'timestamp': order['orderDate'],
    };

    switch (status.toLowerCase()) {
      case 'pending':
        notification.addAll({
          'title': 'Order Received!',
          'message':
              'Your order #$orderNumber has been received and is being processed.',
          'icon': Icons.receipt.codePoint,
          'color': Colors.orange.value,
        });
        break;
      case 'preparing':
        notification.addAll({
          'title': 'Order Preparing',
          'message':
              'Your order #$orderNumber is being prepared in the kitchen.',
          'icon': Icons.restaurant.codePoint,
          'color': Colors.blue.value,
        });
        break;
      case 'on the way':
        notification.addAll({
          'title': 'Order On The Way!',
          'message': 'Your order #$orderNumber is on its way to you.',
          'icon': Icons.delivery_dining.codePoint,
          'color': Colors.green.value,
        });
        break;
      case 'delivered':
        notification.addAll({
          'title': 'Order Delivered!',
          'message':
              'Your order #$orderNumber has been delivered successfully.',
          'icon': Icons.check_circle.codePoint,
          'color': Colors.purple.value,
        });
        break;
      case 'cancelled':
        notification.addAll({
          'title': 'Order Cancelled',
          'message': 'Your order #$orderNumber has been cancelled.',
          'icon': Icons.cancel.codePoint,
          'color': Colors.red.value,
        });
        break;
      default:
        notification.addAll({
          'title': 'Order Update',
          'message': 'Your order #$orderNumber status: $status',
          'icon': Icons.info.codePoint,
          'color': Colors.grey.value,
        });
    }

    return notification;
  }

  Future<void> _markAsRead(int index) async {
    if (notifications[index]['isRead'] == false) {
      setState(() {
        notifications[index]['isRead'] = true;
      });
      await _saveNotifications();
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationsList = notifications.map((notification) {
      return jsonEncode(notification);
    }).toList();
    await prefs.setStringList('notifications', notificationsList);

    // Check if push notifications are enabled
    if (!pushNotificationsEnabled) {
      // Silent save lang, walang sound or popup
      return;
    }

    // Kung naka-on, pwede mo ilagay dito yung code para sa actual push notification
    // Example: showNotificationSound() or showNotificationPopup()
  }

  Future<void> _clearAllNotifications() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkMode ? Colors.grey[800] : Colors.white,
        title: Text('Clear All Notifications',
            style: TextStyle(color: darkMode ? Colors.white : Colors.black)),
        content: Text(
            'Are you sure you want to clear all notifications permanently?',
            style:
                TextStyle(color: darkMode ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () async {
              // Add all current notification IDs to cleared list
              for (var notification in notifications) {
                clearedNotifications.add(notification['id']);
              }

              // Save cleared notifications and clear current notifications
              await _saveClearedNotifications();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('notifications');

              setState(() {
                notifications.clear();
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All notifications permanently cleared'),
                  backgroundColor: darkMode ? Colors.grey[700] : null,
                ),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Method to cancel order (needed for OrderHistoryScreen)
  Future<void> _cancelOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistoryList = prefs.getStringList('order_history') ?? [];

    // Update the order status to cancelled
    for (int i = 0; i < orderHistoryList.length; i++) {
      Map<String, dynamic> order = jsonDecode(orderHistoryList[i]);
      if (order['id'] == orderId) {
        order['status'] = 'Cancelled';
        orderHistoryList[i] = jsonEncode(order);
        break;
      }
    }

    await prefs.setStringList('order_history', orderHistoryList);
    _loadOrderHistory(); // Refresh the list

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order cancelled successfully'),
        backgroundColor: darkMode ? Colors.grey[700] : null,
      ),
    );
  }

  // Method to clear order history (needed for OrderHistoryScreen)
  Future<void> _clearOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('order_history');
    _loadOrderHistory(); // Refresh the list

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order history cleared successfully'),
        backgroundColor: darkMode ? Colors.grey[700] : null,
      ),
    );
  }

  // Method to navigate to order tracking
  void _navigateToTracking(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(order: order),
      ),
    );
  }

  // Simplified notification tap handler - direct to order history
  void _handleNotificationTap(Map<String, dynamic> notification, int index) {
    _markAsRead(index);

    if (notification['type'] == 'order') {
      // Direct navigation to order history
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
      ).then((_) {
        _loadData();
      });
    }
  }

  String _getRelativeTime(String timestamp) {
    try {
      DateTime notificationTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(notificationTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return 'Recently';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  String getGroupTime(String timestamp) {
    try {
      DateTime notificationTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(Duration(days: 1));
      DateTime notificationDate = DateTime(
          notificationTime.year, notificationTime.month, notificationTime.day);

      if (notificationDate == today) {
        return 'Today';
      } else if (notificationDate == yesterday) {
        return 'Yesterday';
      } else {
        return 'Earlier';
      }
    } catch (e) {
      return 'Earlier';
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupNotificationsByTime() {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var notification in notifications) {
      String groupKey = getGroupTime(notification['timestamp']);
      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(notification);
    }

    return grouped;
  }

  Future<void> _deleteNotification(int globalIndex) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkMode ? Colors.grey[800] : Colors.white,
        title: Text('Delete Notification',
            style: TextStyle(color: darkMode ? Colors.white : Colors.black)),
        content: Text(
            'Are you sure you want to delete this notification permanently?',
            style:
                TextStyle(color: darkMode ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () async {
              // Add to cleared notifications to prevent regeneration
              String notificationId = notifications[globalIndex]['id'];
              clearedNotifications.add(notificationId);
              await _saveClearedNotifications();

              setState(() {
                notifications.removeAt(globalIndex);
              });
              await _saveNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification permanently deleted'),
                  backgroundColor: darkMode ? Colors.grey[700] : null,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          title: Text('Notifications'),
          backgroundColor: darkMode ? Colors.grey[800] : Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (notifications.isEmpty) {
      return Scaffold(
        backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          title: Text('Notifications'),
          backgroundColor: darkMode ? Colors.grey[800] : Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('No notifications yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('You\'ll see order updates and promotions here',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    Map<String, List<Map<String, dynamic>>> groupedNotifications =
        _groupNotificationsByTime();

    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: darkMode ? Colors.grey[800] : Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
              icon: Icon(Icons.clear_all), onPressed: _clearAllNotifications),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, sectionIndex) {
          String timeGroup = groupedNotifications.keys.elementAt(sectionIndex);
          List<Map<String, dynamic>> sectionNotifications =
              groupedNotifications[timeGroup]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  timeGroup,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkMode ? Colors.white : Colors.grey[600]),
                ),
              ),
              ...sectionNotifications.map((notification) {
                int globalIndex = notifications.indexOf(notification);

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: notification['isRead']
                        ? (darkMode ? Colors.grey[800] : Colors.white)
                        : (darkMode
                            ? Colors.grey[700]
                            : Colors.orange.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notification['isRead']
                          ? (darkMode
                              ? Colors.grey[600]!
                              : Colors.grey.withOpacity(0.3))
                          : Colors.orange.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Dismissible(
                    key: Key(notification['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) =>
                        _deleteNotification(globalIndex),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(notification['color']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconData(notification['icon'],
                              fontFamily: 'MaterialIcons'),
                          color: Color(notification['color']),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: notification['isRead']
                              ? (darkMode ? Colors.white70 : Colors.black87)
                              : (darkMode ? Colors.white : Colors.black),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            notification['message'],
                            style: TextStyle(
                                color: darkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getRelativeTime(notification['timestamp']),
                                style: TextStyle(
                                    color: darkMode
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                                    fontSize: 12),
                              ),
                              Row(
                                children: [
                                  if (notification['type'] == 'order')
                                    Icon(Icons.shopping_bag,
                                        size: 16,
                                        color: darkMode
                                            ? Colors.grey[500]
                                            : Colors.grey[500]),
                                  SizedBox(width: 4),
                                  if (!notification['isRead'])
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () =>
                          _handleNotificationTap(notification, globalIndex),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
