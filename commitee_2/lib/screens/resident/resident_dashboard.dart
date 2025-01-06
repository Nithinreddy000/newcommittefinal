import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../models/visitor_pass.dart';
import '../../providers/visitor_pass_provider.dart';
import '../../providers/poll_provider.dart';
import '../../providers/facility_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../services/auth_service.dart';
import '../../models/poll.dart';
import '../../models/announcement.dart';
import 'visitor/generate_pass_screen.dart';
import 'facility/facility_booking_screen.dart';
import '../auth/login_screen.dart';
import '../../screens/common/polls/poll_screen.dart';
import '../../providers/security_provider.dart';
import '../../models/security_staff.dart';

class ResidentDashboard extends StatelessWidget {
  const ResidentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resident Dashboard'),
          actions: [
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
            isScrollable: true,
            tabs: [
              Tab(text: 'Announcements'),
              Tab(text: 'Facilities'),
              Tab(text: 'Visitors'),
              Tab(text: 'Polls'),
              Tab(text: 'Security Staff'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnnouncementsTab(context),
            _buildFacilitiesTab(context),
            _buildVisitorsTab(context),
            const PollScreen(canCreate: true),
            _buildSecurityStaffTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        final announcements = provider.announcements
            .where((a) => a.visibleTo.contains('resident'))
            .toList();

        if (announcements.isEmpty) {
          return const Center(
            child: Text('No announcements available'),
          );
        }

        return ListView.builder(
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: _getPriorityIcon(announcement.priority),
                title: Text(announcement.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(announcement.content),
                    const SizedBox(height: 4),
                    Text(
                      'Posted by ${announcement.postedBy} on ${announcement.datePosted.toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFacilitiesTab(BuildContext context) {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FacilityBookingScreen(),
                  ),
                ),
                child: const Text('Book Facility'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.facilities.length,
                itemBuilder: (context, index) {
                  final facility = provider.facilities[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(facility.name),
                      subtitle: Text(facility.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          // Show booking calendar
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVisitorsTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GeneratePassScreen(),
              ),
            ),
            child: const Text('Generate Visitor Pass'),
          ),
        ),
        Expanded(
          child: Consumer<VisitorPassProvider>(
            builder: (context, provider, child) {
              final passes = provider.passes;

              return ListView.builder(
                itemCount: passes.length,
                itemBuilder: (context, index) {
                  final pass = passes[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(pass.visitorName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Purpose: ${pass.purpose}'),
                          Text('Status: ${pass.status}'),
                          Text('Visit Date: ${pass.visitDate.toString().split(' ')[0]}'),
                        ],
                      ),
                      onTap: () {
                        _showPassDetailsDialog(context, pass);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getPriorityIcon(AnnouncementPriority priority) {
    IconData iconData;
    Color color;

    switch (priority) {
      case AnnouncementPriority.low:
        iconData = Icons.info_outline;
        color = Colors.blue;
        break;
      case AnnouncementPriority.normal:
        iconData = Icons.info;
        color = Colors.green;
        break;
      case AnnouncementPriority.high:
        iconData = Icons.warning;
        color = Colors.orange;
        break;
      case AnnouncementPriority.urgent:
        iconData = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(iconData, color: color);
  }

  void _showPassDetailsDialog(BuildContext context, VisitorPass pass) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pass.visitorName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Purpose: ${pass.purpose}'),
                  Text('Status: ${pass.status}'),
                  Text('Visit Date: ${pass.visitDate.toString().split(' ')[0]}'),
                  Text('Contact: ${pass.contactNumber}'),
                  Text('Flat Number: ${pass.flatNumber}'),
                  const SizedBox(height: 24),
                  Center(
                    child: QrImageView(
                      data: jsonEncode(pass.toQRData()),
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityStaffTab(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, provider, child) {
        final activeStaff = provider.activeStaff;

        if (activeStaff.isEmpty) {
          return const Center(child: Text('No active security staff available.'));
        }

        return ListView.builder(
          itemCount: activeStaff.length,
          itemBuilder: (context, index) {
            final staff = activeStaff[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(staff.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${staff.location}'),
                    Text('Contact: ${staff.contactNumber}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    _confirmCall(context, staff.contactNumber);
                  },
                ),
                onTap: () {
                  _showReportDialog(context, staff);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _confirmCall(BuildContext context, String contactNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Call'),
          content: Text('Do you want to call $contactNumber?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement the call functionality here
                Navigator.pop(context);
              },
              child: const Text('Call'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, SecurityStaff staff) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Security Staff'),
          content: Text('Do you want to report ${staff.name} for pretending to be active?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement reporting logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted successfully')),
                );
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }
}