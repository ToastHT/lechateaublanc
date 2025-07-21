import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Common Questions', [
            _buildFAQItem(
              'How do I place an order?',
              'Browse our menu, select items, add to cart, and proceed to checkout.',
              Icons.shopping_cart_outlined,
            ),
            _buildFAQItem(
              'What payment methods do you accept?',
              'We accept credit cards, debit cards, and cash on delivery.',
              Icons.payment_outlined,
            ),
            _buildFAQItem(
              'How can I track my order?',
              'Go to Order History and tap on any active order to track its status.',
              Icons.track_changes_outlined,
            ),
            _buildFAQItem(
              'Can I cancel my order?',
              'Yes, you can cancel orders before they are marked as "Preparing".',
              Icons.cancel_outlined,
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection('Account & Profile', [
            _buildFAQItem(
              'How do I update my profile?',
              'Go to Profile Settings > Personal Data to update your information.',
              Icons.person_outline,
            ),
            _buildFAQItem(
              'How do I change my password?',
              'Go to Settings > Account Security to change your password.',
              Icons.lock_outline,
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection('Delivery & Pickup', [
            _buildFAQItem(
              'What are your delivery hours?',
              'We deliver from 8:00 AM to 10:00 PM daily.',
              Icons.access_time_outlined,
            ),
            _buildFAQItem(
              'How much is the delivery fee?',
              'Delivery fee varies by location. Free delivery for orders over ₱500.',
              Icons.local_shipping_outlined,
            ),
          ]),
          const SizedBox(height: 30),
          _buildContactSection(context),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer, IconData icon) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Still need help?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Call Us'),
                subtitle: const Text('+63 912 345 6789'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showComingSoon(context, 'Call feature'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text('Email Support'),
                subtitle: const Text('support@foodapp.com'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showComingSoon(context, 'Email support'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.orange),
                title: const Text('Live Chat'),
                subtitle: const Text('Chat with our support team'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showComingSoon(context, 'Live chat'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
