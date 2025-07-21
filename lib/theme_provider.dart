import 'package:flutter/material.dart';
import 'settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // Light Theme
  ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.grey[600]),
          headlineSmall: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange;
            }
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.3);
          }),
        ),
      );

  // Dark Theme - Aesthetic dark mode with proper contrast
  ThemeData get darkTheme => ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[700], // Dark gray background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange, // Keep orange AppBar
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: Colors.grey[600], // Dark cards for better aesthetic
          elevation: 2,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // White text
          bodyMedium:
              TextStyle(color: Colors.grey[300]), // Light gray subtitles
          headlineSmall: TextStyle(color: Colors.white), // White headers
        ),
        iconTheme: IconThemeData(color: Colors.white), // White icons
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange;
            }
            return Colors.grey[400];
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.orange.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.3);
          }),
        ),
        // Dark themed components
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[600],
          titleTextStyle: TextStyle(color: Colors.white),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[800],
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[600],
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey[300],
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.grey[600],
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.grey[600],
          textStyle: TextStyle(color: Colors.white),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[500],
        ),
        // Additional components for complete dark theme
        listTileTheme: ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[600]),
          ),
        ),
      );

  // Initialize theme from saved preferences
  Future initializeTheme() async {
    _isDarkMode = await SettingsService.getDarkMode();
    notifyListeners();
  }

  // Toggle theme
  Future toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await SettingsService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  // Set theme directly
  Future setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await SettingsService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}
