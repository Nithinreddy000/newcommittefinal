// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import '../config/email_config.dart';
import 'email_service_interface.dart';

class EmailServiceWeb implements EmailServiceInterface {
  static final String _residentTemplateId = 'template_908etfo';
  static final String _idTemplateId = 'template_63rp7kp';
  static final String _serviceId = EmailConfig.serviceId;

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

      if (kIsWeb) {
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

        return true;
      } else {
        // For non-web platforms, log the attempt
        if (kDebugMode) {
          print('Would send email with parameters: $templateParams');
          print('Using template: $templateId for role: $role');
        }
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending email: $e');
      }
      return false;
    }
  }

  @override
  Future<void> sendWelcomeEmail({
    required String toName,
    required String toEmail,
  }) async {
    if (kDebugMode) {
      print('Sending welcome email to $toEmail');
    }
  }
}
