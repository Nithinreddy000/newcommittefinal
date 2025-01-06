import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/facility_provider.dart';
import '../../../models/facility.dart';
import '../../../models/facility_booking_new.dart';
import '../../../services/auth_service.dart';
import '../../../mixins/form_validation_mixin.dart';

class FacilityBookingScreen extends StatefulWidget {
  const FacilityBookingScreen({super.key});

  @override
  State<FacilityBookingScreen> createState() => _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends State<FacilityBookingScreen> with FormValidationMixin {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  Facility? _selectedFacility;
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Facility'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFacilitySelector(),
            const SizedBox(height: 16),
            _buildCalendar(),
            const SizedBox(height: 16),
            _buildTimeSlotSelector(),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook ? _bookFacility : null,
                child: const Text('Book Facility'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitySelector() {
    return Consumer<FacilityProvider>(
      builder: (context, provider, child) {
        return DropdownButtonFormField<Facility>(
          value: _selectedFacility,
          decoration: const InputDecoration(
            labelText: 'Select Facility',
            border: OutlineInputBorder(),
          ),
          items: provider.facilities.map((facility) {
            return DropdownMenuItem(
              value: facility,
              child: Text(facility.name),
            );
          }).toList(),
          onChanged: (facility) {
            setState(() {
              _selectedFacility = facility;
            });
          },
        );
      },
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time Slot:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TimeSlot.values.map((slot) {
            return ChoiceChip(
              label: Text(_getSlotText(slot)),
              selected: _selectedTimeSlot == slot,
              onSelected: (selected) {
                setState(() {
                  _selectedTimeSlot = selected ? slot : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  bool get _canBook {
    return _selectedFacility != null && _selectedTimeSlot != null;
  }

  void _bookFacility() {
    if (!_canBook) return;

    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    final booking = FacilityBooking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      facilityId: _selectedFacility!.id,
      facilityName: _selectedFacility!.name,
      userId: currentUser.id,
      bookingDate: _selectedDay,
      timeSlot: _selectedTimeSlot!,
      status: BookingStatus.pending,
      notes: _notesController.text,
    );

    context.read<FacilityProvider>().addBooking(booking);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking request submitted')),
    );
  }

  String _getSlotText(TimeSlot slot) {
    switch (slot) {
      case TimeSlot.morning:
        return 'Morning';
      case TimeSlot.afternoon:
        return 'Afternoon';
      case TimeSlot.evening:
        return 'Evening';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
} 