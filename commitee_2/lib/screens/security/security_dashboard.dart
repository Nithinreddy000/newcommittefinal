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
import '../common/profile_screen.dart';
import '../../screens/common/polls/poll_screen.dart';
import '../../providers/security_provider.dart';
import '../../models/security_staff.dart';

class SecurityDashboard extends StatelessWidget {
  const SecurityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Security Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                final authService = context.read<AuthService>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Provider.value(
                      value: authService.currentUser,
                      child: const ProfileScreen(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AuthService>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Polls'),
            ],
          ),
        ),
        body: Consumer<SecurityProvider>(
          builder: (context, provider, child) {
            // Check if staff exists in the list
            SecurityStaff? existingStaff = provider.activeStaff
                .where((s) => s.id == currentUser.id)
                .firstOrNull;

            // If staff doesn't exist, create a new one
            if (existingStaff == null) {
              existingStaff = SecurityStaff(
                id: currentUser.id,
                name: currentUser.name ?? 'Unknown',
                location: 'Unknown',
                contactNumber: 'Unknown',
                isActive: false,
              );
              // Add the new staff to the provider
              provider.addStaff(existingStaff);
            }

            final staff = existingStaff;

            return TabBarView(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${staff.isActive ? "Active" : "Inactive"}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: staff.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          Switch(
                            value: staff.isActive,
                            activeColor: Colors.green,
                            onChanged: (bool value) {
                              provider.toggleActiveStatus(staff.id);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: staff.isActive 
                        ? _buildDashboardGrid(context)
                        : const Center(
                            child: Text(
                              'Please activate your status to access security features',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                    ),
                  ],
                ),
                const PollScreen(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      children: [
        DashboardCard(
          title: 'Visitor Entry',
          icon: Icons.person_add,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VisitorEntryScreen(),
            ),
          ),
        ),
        DashboardCard(
          title: 'Visitor Log',
          icon: Icons.list_alt,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitorLogScreen(),
            ),
          ),
        ),
        DashboardCard(
          title: 'Emergency',
          icon: Icons.emergency,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmergencyScreen(),
            ),
          ),
        ),
        DashboardCard(
          title: 'Reports',
          icon: Icons.report,
          onTap: () {
            // TODO: Implement security reports
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reports coming soon!')),
            );
          },
        ),
        DashboardCard(
          title: 'Announcements',
          icon: Icons.announcement,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SecurityAnnouncementsScreen(),
            ),
          ),
        ),
        DashboardCard(
          title: 'Scan QR',
          icon: Icons.qr_code_scanner,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScannerScreen(),
            ),
          ),
        ),
      ],
    );
  }
}