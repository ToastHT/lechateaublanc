class User {
  final String id;
  final String email;
  final String username;
  final bool isAdmin;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isAdmin,
  });
}

class UserService {
  static List<User> _users = [
    User(id: '1', email: 'admin@gmail.com', username: 'admin', isAdmin: true),
  ];

  static Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Admin login
    if (email == 'admin@gmail.com' && password == 'admin') {
      return _users.firstWhere((user) => user.isAdmin);
    }

    // User login
    try {
      return _users.firstWhere(
        (user) => user.email == email && !user.isAdmin,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> register(
      String email, String username, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Check if user already exists
    bool userExists = _users.any((user) => user.email == email);
    if (userExists) {
      return false;
    }

    // Add new user
    _users.add(User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      username: username,
      isAdmin: false,
    ));

    return true;
  }

  static List<User> getAllUsers() {
    return _users.where((user) => !user.isAdmin).toList();
  }

  static bool deleteUser(String userId) {
    int initialLength = _users.length;
    _users.removeWhere((user) => user.id == userId && !user.isAdmin);
    return _users.length < initialLength;
  }
}
