import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_service.dart';
import 'theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final push = await SettingsService.getPushNotifications();
    final lang = await SettingsService.getLanguage();

    setState(() {
      pushNotifications = push;
      selectedLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Notifications', [
            _buildSwitchTile(
              'Push Notifications',
              'Receive push notifications for orders and promotions',
              pushNotifications,
              (value) async {
                await SettingsService.setPushNotifications(value);
                setState(() => pushNotifications = value);
              },
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection('Appearance', [
            _buildSwitchTile(
              'Dark Mode',
              'Switch to dark theme',
              themeProvider.isDarkMode,
              (value) async {
                await themeProvider.setTheme(value);
              },
            ),
            _buildDropdownTile(
              'Language',
              'Select your preferred language',
              selectedLanguage,
              ['English', 'Filipino', 'Spanish'],
              (value) async {
                await SettingsService.setLanguage(value);
                setState(() => selectedLanguage = value);
              },
            ),
          ]),
          const SizedBox(height: 20),
          _buildSection('Privacy', [
            _buildTile('Privacy Policy', 'View our privacy policy', () {
              _showComingSoon('Privacy Policy');
            }),
            _buildTile('Terms of Service', 'View terms and conditions', () {
              _showComingSoon('Terms of Service');
            }),
          ]),
          const SizedBox(height: 20),
          _buildSection('About', [
            _buildTile('App Version', 'Version 1.0.0', () {}),
            _buildTile('Rate App', 'Rate us on the app store', () {
              _showComingSoon('Rate App');
            }),
          ]),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.orange,
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value,
      List<String> items, Function(String) onChanged) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: Theme.of(context).cardTheme.color,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: Theme.of(context).textTheme.bodyLarge),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
