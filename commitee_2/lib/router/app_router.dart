import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/admin_dashboard.dart';
import '../screens/resident_dashboard.dart';
import '../screens/security_dashboard.dart';
import '../services/auth_service.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case '/resident':
        return MaterialPageRoute(builder: (_) => const ResidentDashboard());
      case '/security':
        return MaterialPageRoute(builder: (_) => const SecurityDashboard());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static String initialRoute(AuthService authService) {
    if (authService.currentUser == null) {
      return '/';
    }
    switch (authService.currentUser!.role) {
      case UserRole.admin:
        return '/admin';
      case UserRole.resident:
        return '/resident';
      case UserRole.security:
        return '/security';
      default:
        return '/';
    }
  }
}

