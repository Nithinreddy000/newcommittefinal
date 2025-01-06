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
import '../common/polls/poll_screen.dart';
import '../../mixins/form_validation_mixin.dart';
import '../../providers/security_provider.dart';

class AdminDashboard extends StatelessWidget with FormValidationMixin {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
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
              Tab(text: 'Polls'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const ManageMembersScreen(),
            const VisitorManagementScreen(),
            const AnnouncementScreen(),
            _buildFacilitiesTab(),
            _buildSecurityStaffTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<FacilityProvider>(
            builder: (context, provider, _) => ElevatedButton(
              onPressed: () => _showAddFacilityDialog(context),
              child: const Text('Add New Facility'),
            ),
          ),
        ),
        Expanded(
          child: Consumer<FacilityProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                itemCount: provider.bookings.length,
                itemBuilder: (context, index) {
                  final booking = provider.bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(booking.facilityName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${_formatDate(booking.bookingDate)}'),
                          Text('Time: ${_getSlotText(booking.timeSlot)}'),
                          Text('Status: ${booking.status}'),
                        ],
                      ),
                      trailing: booking.status == BookingStatus.pending
                          ? ElevatedButton(
                              onPressed: () => provider.approveBooking(booking.id),
                              child: const Text('Approve'),
                            )
                          : null,
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

  void _showAddFacilityDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Facility'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Facility Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validateRequired(value, 'Facility name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validateRequired(value, 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: iconController,
                    decoration: const InputDecoration(
                      labelText: 'Icon Name*',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., pool, gym, hall',
                    ),
                    validator: (value) => validateRequired(value, 'Icon name'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final facility = Facility(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    icon: iconController.text.trim(),
                  );
                  context.read<FacilityProvider>().addFacility(facility);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Facility added successfully')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecurityStaffTab() {
    return Consumer<SecurityProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.activeStaff.length,
          itemBuilder: (context, index) {
            final staff = provider.activeStaff[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(staff.name),
                subtitle: Text('Location: ${staff.location}'),
                trailing: Text(
                  staff.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: staff.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
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