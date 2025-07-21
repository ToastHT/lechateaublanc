import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Payment extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double total;
  final bool isAdmin;

  Payment(
      {required this.cartItems, required this.total, required this.isAdmin});

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String selectedPaymentMethod = 'Cash on Delivery';
  bool _isProcessingPayment = false;

  String customerName = 'Albert Stevens';
  String customerPhone = '+2441947 4968';
  String customerAddress = 'Apartment No. 123, New York, Cuba, BC54';

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in widget.cartItems) {
      String priceStr = item['price'].replaceAll('P ', '').replaceAll(',', '');
      double price = double.tryParse(priceStr) ?? 0;
      subtotal += price * item['quantity'];
    }
    return subtotal;
  }

  double _calculateTax() => _calculateSubtotal() * 0.10;
  double _calculateFinalTotal() => _calculateSubtotal() + _calculateTax();

  Future<void> _saveOrderToHistory(Map<String, dynamic> order) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistory = prefs.getStringList('order_history') ?? [];
    orderHistory.add(jsonEncode(order));
    await prefs.setStringList('order_history', orderHistory);
  }

  void _editAddress() {
    TextEditingController nameController =
        TextEditingController(text: customerName);
    TextEditingController phoneController =
        TextEditingController(text: customerPhone);
    TextEditingController addressController =
        TextEditingController(text: customerAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone')),
            TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                customerName = nameController.text;
                customerPhone = phoneController.text;
                customerAddress = addressController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _processGCashPayment() {
    setState(() => _isProcessingPayment = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('GCash Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 60),
                  Text('GCash QR Code'),
                  Text('Aldrich Mira'),
                  Text('09485890347'),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Total: ₱${_calculateFinalTotal().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isProcessingPayment = false);
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _placeOrder();
            },
            child: Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> order = {
      'id': orderId,
      'items': widget.cartItems,
      'total': _calculateFinalTotal(),
      'paymentMethod': selectedPaymentMethod,
      'orderDate': DateTime.now().toIso8601String(),
      'status': 'Pending',
      'deliveryAddress': {
        'name': customerName,
        'phone': customerPhone,
        'address': customerAddress,
      }
    };

    await _saveOrderToHistory(order);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Order Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order ID: ${orderId.substring(0, 8)}'),
            Text('Total: ₱${_calculateFinalTotal().toStringAsFixed(2)}'),
            Text('Payment: $selectedPaymentMethod'),
            SizedBox(height: 8),
            Text('Delivery to: $customerName'),
            Text(customerAddress),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Payment Method
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Method',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    _buildPaymentOption('Cash on Delivery', Icons.money),
                    _buildPaymentOption('GCash', Icons.account_balance_wallet),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Items
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Items (${widget.cartItems.length})',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    ...widget.cartItems
                        .map((item) => Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(item['image']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(child: Text(item['name'])),
                                  Text('x${item['quantity']}'),
                                  SizedBox(width: 8),
                                  Text(item['price'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange)),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Total & Address
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Subtotal',
                        '₱${_calculateSubtotal().toStringAsFixed(2)}'),
                    _buildDetailRow(
                        'Tax (10%)', '₱${_calculateTax().toStringAsFixed(2)}'),
                    Divider(),
                    _buildDetailRow('Total',
                        '₱${_calculateFinalTotal().toStringAsFixed(2)}',
                        isTotal: true),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                            onPressed: _editAddress, child: Text('Edit')),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customerName,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(customerPhone),
                          Text(customerAddress),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isProcessingPayment
              ? null
              : () {
                  selectedPaymentMethod == 'GCash'
                      ? _processGCashPayment()
                      : _placeOrder();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isProcessingPayment
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white)),
                    SizedBox(width: 8),
                    Text('Processing...',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                )
              : Text(
                  selectedPaymentMethod == 'GCash'
                      ? 'Pay with GCash'
                      : 'Place Order',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => selectedPaymentMethod = title),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedPaymentMethod == title
                  ? Colors.orange
                  : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
            color: selectedPaymentMethod == title
                ? Colors.orange.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: selectedPaymentMethod == title
                      ? Colors.orange
                      : Colors.grey[600]),
              SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                    fontWeight: selectedPaymentMethod == title
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedPaymentMethod == title
                        ? Colors.orange
                        : Colors.black,
                  )),
              Spacer(),
              if (selectedPaymentMethod == title)
                Icon(Icons.check_circle, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.orange : Colors.black,
              )),
        ],
      ),
    );
  }
}
