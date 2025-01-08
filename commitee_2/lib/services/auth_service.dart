import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/notification_provider.dart';

enum UserRole {
  admin,
  resident,
  security,
}

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
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    final userCred = _userCredentials[email.toLowerCase()];
    if (userCred != null && userCred['password'] == password) {
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': userCred['name'] ?? 'User',
        'role': userCred['role']!,
        'email': email.toLowerCase(),
        if (userCred['flatNumber'] != null) 'flatNumber': userCred['flatNumber']!,
        if (userCred['idNumber'] != null) 'idNumber': userCred['idNumber']!,
      };
    }
    return null;
  }

  Future<String> registerUser(
    String email,
    String password,
    String role,
    String name,
    String? flatNumber,
    String? idNumber,
  ) async {
    final normalizedEmail = email.toLowerCase();
    _userCredentials[normalizedEmail] = {
      'password': password,
      'role': role,
      'name': name,
      if (flatNumber != null) 'flatNumber': flatNumber,
      if (idNumber != null) 'idNumber': idNumber,
    };
    notifyListeners();
    return password;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCred = await _validateCredentials(email, password);
      if (userCred != null) {
        _currentUser = User(
          id: userCred['id']!,
          email: userCred['email']!,
          name: userCred['name']!,
          role: userCred['role']!,
          flatNumber: userCred['flatNumber'],
          idNumber: userCred['idNumber'],
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        throw 'Invalid email or password. Please try again.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
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

  void removeUser(String email) {
    _userCredentials.remove(email.toLowerCase());
    notifyListeners();
  }

  Future<void> updateUserEmail(
    String oldEmail,
    String newEmail,
    String name,
    String role,
    String? flatNumber,
    String? idNumber,
  ) async {
    final userData = _userCredentials.remove(oldEmail.toLowerCase());
    if (userData != null) {
      _userCredentials[newEmail.toLowerCase()] = {
        ...userData,
        'name': name,
        'role': role,
        if (flatNumber != null) 'flatNumber': flatNumber,
        if (idNumber != null) 'idNumber': idNumber,
      };
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    final userCred = _userCredentials[_currentUser!.email];
    if (userCred == null) {
      throw Exception('User not found');
    }

    if (userCred['password'] != currentPassword) {
      throw Exception('Current password is incorrect');
    }

    _userCredentials[_currentUser!.email]!['password'] = newPassword;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update the user credentials in the map
      final oldEmail = _currentUser!.email.toLowerCase();
      final userCred = _userCredentials[oldEmail];
      
      if (userCred != null) {
        // If email is being changed, move the credentials to new email key
        if (email.toLowerCase() != oldEmail) {
          _userCredentials.remove(oldEmail);
          _userCredentials[email.toLowerCase()] = {
            ...userCred,
            'name': name,
          };
        } else {
          userCred['name'] = name;
        }

        // Update current user
        _currentUser = User(
          id: _currentUser!.id,
          name: name,
          email: email,
          role: _currentUser!.role,
          flatNumber: _currentUser?.flatNumber,
          idNumber: _currentUser?.idNumber,
        );

        notifyListeners();
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // For debugging purposes
  void printUserCredentials() {
    debugPrint('Current User Credentials:');
    _userCredentials.forEach((email, data) {
      debugPrint('Email: $email');
      debugPrint('Data: $data');
    });
  }
}
