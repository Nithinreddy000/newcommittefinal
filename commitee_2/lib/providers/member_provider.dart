import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/member.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';

class MemberProvider extends ChangeNotifier {
  final List<Member> _members = [];
  final AuthService _authService;

  MemberProvider(this._authService);

  List<Member> get members => List.unmodifiable(_members);

  Future<(bool, String)> addMember({
    required String name,
    required String email,
    String? flatNumber,
    String? idNumber,
    required String contactNumber,
    required String role,
  }) async {
    // Generate a random password
    final password = generatePassword();

    try {
      // Register the user with AuthService
      await _authService.registerUser(
        email,
        password,
        role,
        name,
        flatNumber,
        idNumber,
      );

      // Create a new member
      final member = Member(
        id: DateTime.now().toString(),
        name: name,
        email: email,
        flatNumber: flatNumber,
        idNumber: idNumber,
        contactNumber: contactNumber,
        role: role,
      );

      _members.add(member);
      notifyListeners();

      // Send welcome email with credentials
      try {
        await EmailService().sendCredentials(
          email: email,
          username: email,
          password: password,
          name: name,
          flatNumber: role == 'resident' ? (flatNumber ?? '') : (idNumber ?? ''),
          role: role,
          contactNumber: contactNumber,
        );
      } catch (e) {
        debugPrint('Failed to send welcome email: $e');
        // Don't throw the error as the member was still created successfully
      }

      return (true, password);
    } catch (e) {
      debugPrint('Failed to add member: $e');
      return (false, '');
    }
  }

  Future<void> updateMember(Member updatedMember) async {
    final index = _members.indexWhere((m) => m.id == updatedMember.id);
    if (index != -1) {
      _members[index] = updatedMember;
      notifyListeners();
    }
  }

  Future<void> removeMember(String id) async {
    _members.removeWhere((member) => member.id == id);
    notifyListeners();
  }

  Future<bool> resendCredentials(Member member) async {
    try {
      final password = generatePassword();
      await EmailService().sendCredentials(
        email: member.email,
        username: member.email,
        password: password,
        name: member.name,
        flatNumber: member.role == 'resident' ? (member.flatNumber ?? '') : (member.idNumber ?? ''),
        role: member.role,
        contactNumber: member.contactNumber,
      );
      return true;
    } catch (e) {
      debugPrint('Failed to resend credentials: $e');
      return false;
    }
  }

  String generatePassword() {
    const length = 12;
    const letterLowercase = 'abcdefghijklmnopqrstuvwxyz';
    const letterUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const number = '0123456789';
    const special = '@#\$%^&*()_+';

    String chars = '';
    chars += letterLowercase;
    chars += letterUppercase;
    chars += number;
    chars += special;

    return List.generate(length, (index) {
      final indexRandom = Random().nextInt(chars.length);
      return chars[indexRandom];
    }).join('');
  }
}