import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/dashboard_card.dart';
import 'visitor/visitor_entry_screen.dart';
import 'visitor/visitor_log_screen.dart';
import 'emergency/emergency_screen.dart';
import 'announcements/security_announcements_screen.dart';
import 'visitor/qr_scanner_screen.dart';
import '../auth/login_screen.dart';
import '../../screens/common/polls/poll_screen.dart';
import '../../providers/security_provider.dart';
import '../../models/security_staff.dart';

class SecurityDashboard extends StatelessWidget {
  const SecurityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser!; // Get the current user

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
      ),
      body: Consumer<SecurityProvider>(
        builder: (context, provider, child) {
          final staff = provider.activeStaff.firstWhere((s) => s.id == currentUser.id, orElse: () => null);

          if (staff == null) {
            return const Center(child: Text('You are not an active security staff.'));
          }

          return Column(
            children: [
              ListTile(
                title: Text('Status: ${staff.isActive ? "Active" : "Inactive"}'),
                trailing: Switch(
                  value: staff.isActive,
                  onChanged: (value) {
                    provider.toggleActiveStatus(staff.id); // Toggle active status
                  },
                ),
              ),
              // Other dashboard functionalities...
            ],
          );
        },
      ),
    );
  }
} 