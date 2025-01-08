import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/facility_provider.dart';
import '../../models/facility.dart';
import '../../models/facility_booking_new.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'members/manage_members_screen.dart';
import 'visitor_management_screen.dart';
import 'announcement_screen.dart';
import 'polls/manage_polls_screen.dart';
import '../../mixins/form_validation_mixin.dart';
import '../../providers/security_provider.dart';
import '../admin/facilities/manage_facilities_screen.dart';
import '../common/profile_screen.dart'; // Fixed import path for ProfileScreen

class AdminDashboard extends StatelessWidget with FormValidationMixin {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Visitors'),
              Tab(text: 'Announcements'),
              Tab(text: 'Facilities'),
              Tab(text: 'Security Staff'),
              Tab(text: 'Polls'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const ManageMembersScreen(),
            const VisitorManagementScreen(),
            const AnnouncementScreen(),
            const ManageFacilitiesScreen(),
            _buildSecurityStaffTab(),
            const ManagePollsScreen(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getSlotText(TimeSlot slot) {
    switch (slot) {
      case TimeSlot.morning:
        return 'Morning (6 AM - 12 PM)';
      case TimeSlot.afternoon:
        return 'Afternoon (12 PM - 6 PM)';
      case TimeSlot.evening:
        return 'Evening (6 PM - 10 PM)';
    }
  }

  Widget _buildSecurityStaffTab() {
    return Consumer<SecurityProvider>(
      builder: (context, provider, child) {
        if (provider.activeStaff.isEmpty) {
          return const Center(
            child: Text('No active security staff at the moment'),
          );
        }

        return ListView.builder(
          itemCount: provider.activeStaff.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final staff = provider.activeStaff[index];
            if (!staff.isActive) return const SizedBox.shrink();
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(staff.name),
                subtitle: Text('Location: ${staff.location}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 