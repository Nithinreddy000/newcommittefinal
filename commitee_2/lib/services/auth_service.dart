import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/notification_provider.dart';

class AuthService extends ChangeNotifier {
  final BuildContext _context;
  User? _currentUser;
  bool _isLoading = false;

  // Add a map to store user credentials
  final Map<String, Map<String, String>> _userCredentials = {
    'admin@test.com': {'password': 'admin123', 'role': 'admin', 'name': 'Admin'},
    'resident@test.com': {'password': 'resident123', 'role': 'resident', 'name': 'Resident', 'flatNumber': 'A101'},
    'security@test.com': {'password': 'security123', 'role': 'security', 'name': 'Security', 'idNumber': 'SEC001'},
  };

  AuthService(this._context);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<Map<String, String>?> _validateCredentials(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final userCred = _userCredentials[email];
    if (userCred != null && userCred['password'] == password) {
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': userCred['name'] ?? 'User',
        'role': userCred['role']!,
        if (userCred['flatNumber'] != null) 'flatNumber': userCred['flatNumber']!,
      };
    }
    return null;
  }

  void registerUser(
    String email,
    String password,
    String role,
    String name,
    String? flatNumber,
    String? idNumber,
  ) {
    _userCredentials[email] = {
      'password': password,
      'role': role,
      'name': name,
      if (flatNumber != null) 'flatNumber': flatNumber,
      if (idNumber != null) 'idNumber': idNumber,
    };
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCred = await _validateCredentials(email, password);
      if (userCred != null) {
        _currentUser = User(
          id: userCred['id']!,
          email: email,
          name: userCred['name']!,
          role: userCred['role']!,
          flatNumber: userCred['flatNumber'],
        );
        notifyListeners();
      } else {
        throw 'Invalid credentials';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      if (!kIsWeb) {
        final notificationProvider = Provider.of<NotificationProvider>(
          _context,
          listen: false,
        );
        for (var topic in notificationProvider.subscribedTopics) {
          await notificationProvider.unsubscribeFromTopic(topic);
        }
      }
      _currentUser = null;
      notifyListeners();
    }
  }
}

