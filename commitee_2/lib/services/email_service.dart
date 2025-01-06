import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import '../config/email_config.dart';

class EmailService {
  static final String _residentTemplateId = 'template_908etfo';
  static final String _securityTemplateId = 'template_63rp7kp';
  static final String _serviceId = EmailConfig.serviceId;

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

      // Prepare template parameters
      final templateParams = {
        'to_email': cleanEmail,
        'to_name': name,
        'identifier': role == 'resident' ? 'Flat Number: $flatNumber' : 'Security ID: $flatNumber',
        'username': username,
        'password': password,
        'contact': contactNumber,
        'reply_to': cleanEmail,
      };

      // Select template based on role
      final templateId = role == 'security' ? _securityTemplateId : _residentTemplateId;

      // Send email using EmailJS
      final result = await js.context.callMethod('sendEmail', [
        _serviceId,
        templateId,
        js.JsObject.jsify(templateParams),
      ]);

      if (kDebugMode) {
        print('Email parameters: $templateParams');
        print('Using template: $templateId for role: $role');
        print('Email sending result: $result');
      }

      return result == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email: $e');
      }
      return false;
    }
  }

  static Future<void> sendWelcomeEmail({
    required String toName,
    required String toEmail,
    required String flatNumber,
    required String password,
  }) async {
    // Implement email sending logic here
    print('Sending welcome email to $toEmail');
  }
} 