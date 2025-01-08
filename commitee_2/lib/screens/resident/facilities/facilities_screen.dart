import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/facility.dart';
import '../../../models/facility_booking.dart';
import '../../../providers/facility_provider.dart';
import '../../../services/auth_service.dart';
import 'facility_booking_screen.dart';

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
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
            _buildAvailableFacilities(context),
            _buildMyBookings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableFacilities(BuildContext context) {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        if (provider.facilities.isEmpty) {
          return const Center(
            child: Text('No facilities available'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.facilities.length,
          itemBuilder: (context, index) {
            final facility = provider.facilities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.business,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          facility.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Available time slots will be shown when booking',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailChip(
                              Icons.access_time,
                              'Check Availability',
                            ),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FacilityBookingScreen(
                                    facility: facility,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Book Now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyBookings(BuildContext context) {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        final user = Provider.of<AuthService>(context, listen: false).currentUser;
        if (user == null) {
          return const Center(child: Text('Please log in to view your bookings'));
        }
        
        final userBookings = provider.getUserBookings(user.id);
        
        if (userBookings.isEmpty) {
          return const Center(
            child: Text('No bookings found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userBookings.length,
          itemBuilder: (context, index) {
            final booking = userBookings[index];
            final facility = provider.getFacility(booking.facilityId);
            
            if (facility == null) return const SizedBox.shrink();

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.business),
                ),
                title: Text(facility.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${_formatDate(booking.date)}'),
                    Text('Time: ${_formatTimeSlot(booking.timeSlot)}'),
                    Text('Status: ${booking.status.name}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (booking.status == BookingStatus.approved || booking.status == BookingStatus.pending)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editBooking(context, booking, facility),
                      ),
                    if (booking.status == BookingStatus.approved || booking.status == BookingStatus.pending)
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _cancelBooking(context, booking.id),
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

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeSlot(TimeSlot slot) {
    return '${slot.startTime} - ${slot.endTime}';
  }

  Future<void> _cancelBooking(BuildContext context, String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<FacilityProvider>(context, listen: false);
        await provider.cancelBooking(bookingId);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel booking: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _editBooking(BuildContext context, FacilityBooking booking, Facility facility) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FacilityBookingScreen(
          facility: facility,
          booking: booking,
          isEditing: true,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully')),
      );
    }
  }
}