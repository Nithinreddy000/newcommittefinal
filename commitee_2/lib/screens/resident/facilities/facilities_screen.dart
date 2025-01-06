import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/facility_provider.dart';
import '../../../models/facility_booking_new.dart';
import '../../../services/auth_service.dart';
import 'facility_booking_screen.dart';

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Facilities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available Facilities'),
              Tab(text: 'My Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFacilitiesList(context),
            _buildBookingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesList(BuildContext context) {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.facilities.length,
          itemBuilder: (context, index) {
            final facility = provider.facilities[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(_getFacilityIcon(facility['icon'])),
                ),
                title: Text(facility['name']),
                subtitle: Text(facility['description']),
                trailing: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacilityBookingScreen(
                        facility: facility,
                      ),
                    ),
                  ),
                  child: const Text('Book'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingsList(BuildContext context) {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        final userId = Provider.of<AuthService>(context, listen: false).currentUser!.id;
        final bookings = provider.getBookingsByUser(userId);

        if (bookings.isEmpty) {
          return const Center(
            child: Text('No bookings found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              child: ListTile(
                title: Text(booking.facilityName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${_formatDate(booking.bookingDate)}'),
                    Text('Time: ${_getSlotText(booking.timeSlot)}'),
                    Text('Status: ${booking.status.name.toUpperCase()}'),
                    if (booking.notes?.isNotEmpty == true)
                      Text('Notes: ${booking.notes}'),
                  ],
                ),
                trailing: _getStatusIcon(booking.status),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  IconData _getFacilityIcon(String icon) {
    switch (icon) {
      case 'fitness':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'hall':
        return Icons.meeting_room;
      default:
        return Icons.sports;
    }
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

  Widget _getStatusIcon(BookingStatus status) {
    IconData iconData;
    Color color;

    switch (status) {
      case BookingStatus.pending:
        iconData = Icons.pending;
        color = Colors.orange;
        break;
      case BookingStatus.approved:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case BookingStatus.rejected:
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case BookingStatus.cancelled:
        iconData = Icons.block;
        color = Colors.grey;
        break;
    }

    return Icon(iconData, color: color);
  }
} 