import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/facility.dart';
import '../../../models/facility_booking.dart';
import '../../../providers/facility_provider.dart';

class ManageFacilitiesScreen extends StatefulWidget {
  const ManageFacilitiesScreen({super.key});

  @override
  State<ManageFacilitiesScreen> createState() => _ManageFacilitiesScreenState();
}

class _ManageFacilitiesScreenState extends State<ManageFacilitiesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Facilities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Facilities'),
              Tab(text: 'Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFacilitiesTab(),
            _buildBookingsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddFacilityDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFacilitiesTab() {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        if (provider.facilities.isEmpty) {
          return const Center(
            child: Text('No facilities available'),
          );
        }

        return ListView.builder(
          itemCount: provider.facilities.length,
          itemBuilder: (context, index) {
            final facility = provider.facilities[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.business),
                ),
                title: Text(facility.name),
                subtitle: Text(facility.description),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditFacilityDialog(context, facility),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        final bookings = provider.bookings;
        
        if (bookings.isEmpty) {
          return const Center(
            child: Text('No bookings available'),
          );
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final facility = provider.getFacility(booking.facilityId);
            
            if (facility == null) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('${booking.userName} - ${facility.name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purpose: ${booking.purpose}'),
                    Text(
                      'Time: ${_formatTimeSlot(booking.timeSlot)}',
                    ),
                    Text('Status: ${booking.status.name}'),
                  ],
                ),
                trailing: booking.status == BookingStatus.pending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _updateBookingStatus(
                              booking,
                              BookingStatus.approved,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _updateBookingStatus(
                              booking,
                              BookingStatus.rejected,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFacilityDialog(BuildContext context) {
    _nameController.clear();
    _descriptionController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Facility'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Description is required' : null,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final provider =
                    Provider.of<FacilityProvider>(context, listen: false);
                provider.addFacility(
                  name: _nameController.text,
                  description: _descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditFacilityDialog(BuildContext context, Facility facility) {
    _nameController.text = facility.name;
    _descriptionController.text = facility.description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Facility'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Description is required' : null,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final provider =
                    Provider.of<FacilityProvider>(context, listen: false);
                provider.updateFacility(
                  facility.copyWith(
                    name: _nameController.text,
                    description: _descriptionController.text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatTimeSlot(TimeSlot slot) {
    return '${slot.startTime} - ${slot.endTime}';
  }

  Future<void> _updateBookingStatus(
    FacilityBooking booking,
    BookingStatus status,
  ) async {
    try {
      final provider = Provider.of<FacilityProvider>(context, listen: false);
      await provider.updateBookingStatus(booking.id, status);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking ${status.name.toLowerCase()}'),
            backgroundColor: status == BookingStatus.approved ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
