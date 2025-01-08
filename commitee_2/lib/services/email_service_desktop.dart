import 'package:flutter/foundation.dart';
import 'email_service_interface.dart';

class EmailServiceDesktop implements EmailServiceInterface {
  @override
  Future<bool> sendCredentials({
    required String email,
    required String username,
    required String password,
    required String name,
    required String flatNumber,
    required String role,
    required String contactNumber,
  }) async {
    // For desktop, just log the credentials that would be sent
    if (kDebugMode) {
      print('Mock email service - Credentials would be sent to: $email');
      print('Name: $name');
      print('Role: $role');
      print('Username: $username');
      print('Password: $password');
      if (role == 'resident') {
        print('Flat Number: $flatNumber');
      } else {
        print('ID Number: $flatNumber');
      }
      print('Contact: $contactNumber');
    }
    return true;
  }

  @override
  Future<void> sendWelcomeEmail({
    required String toName,
    required String toEmail,
  }) async {
    if (kDebugMode) {
      print('Mock email service - Welcome email would be sent to: $toEmail');
    }
  }
}
