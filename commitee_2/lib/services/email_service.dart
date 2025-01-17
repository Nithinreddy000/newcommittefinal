import 'package:flutter/foundation.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  static final String _residentTemplateId = 'template_908etfo';
  static final String _idTemplateId = 'template_63rp7kp';
  static final String _serviceId = 'service_2rigpdj';

  factory EmailService() {
    return _instance;
  }

  EmailService._internal();

  Future<bool> sendCredentials({
    required String email,
    required String username,
    required String password,
    required String name,
    required String flatNumber,
    required String role,
    required String contactNumber,
  }) async {
    try {
      final cleanEmail = email.trim();
      
      if (kDebugMode) {
        print('Attempting to send email to: $cleanEmail');
      }

      final templateParams = {
        'to_email': cleanEmail,
        'to_name': name,
        'flat_number': flatNumber,
        'username': username,
        'password': password,
        'contact': contactNumber,
        'reply_to': cleanEmail,
      };

      final templateId = role == 'resident' ? _residentTemplateId : _idTemplateId;

      // Log the attempt regardless of platform
      if (kDebugMode) {
        print('Email parameters:');
        print('  To: $cleanEmail');
        print('  Name: $name');
        print('  Role: $role');
        print('  Template: $templateId');
        print('  Username: $username');
        print('  Password: $password');
        if (role == 'resident') {
          print('  Flat Number: $flatNumber');
        } else {
          print('  ID Number: $flatNumber');
        }
      }

      // Return true to simulate success on non-web platforms
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email: $e');
      }
      return false;
    }
  }

  Future<void> sendWelcomeEmail({
    required String toName,
    required String toEmail,
  }) async {
    if (kDebugMode) {
      print('Would send welcome email to:');
      print('  Name: $toName');
      print('  Email: $toEmail');
    }
  }
}