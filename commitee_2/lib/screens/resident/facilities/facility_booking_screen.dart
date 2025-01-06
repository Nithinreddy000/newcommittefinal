import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/facility_provider.dart';
import '../../../models/facility_booking_new.dart';
import '../../../services/auth_service.dart';

class FacilityBookingScreen extends StatefulWidget {
  final Map<String, dynamic> facility;

  const FacilityBookingScreen({
    super.key,
    required this.facility,
  });

  @override
  State<FacilityBookingScreen> createState() => _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends State<FacilityBookingScreen> {
  DateTime _selectedDay = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.facility['name']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _selectedTimeSlot = null;
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
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Time Slot:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer<FacilityProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: TimeSlot.values.map((slot) {
                    final isAvailable = provider.isSlotAvailable(
                      widget.facility['id'],
                      _selectedDay,
                      slot,
                    );
                    return RadioListTile<TimeSlot>(
                      title: Text(_getSlotText(slot)),
                      value: slot,
                      groupValue: _selectedTimeSlot,
                      onChanged: isAvailable
                          ? (value) {
                              setState(() {
                                _selectedTimeSlot = value;
                              });
                            }
                          : null,
                      subtitle: Text(
                        isAvailable ? 'Available' : 'Not Available',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _selectedTimeSlot == null ? null : _submitBooking,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Submit Booking'),
        ),
      ),
    );
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

  void _submitBooking() {
    final user = context.read<AuthService>().currentUser!;
    final booking = FacilityBooking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      facilityId: widget.facility['id'],
      facilityName: widget.facility['name'],
      bookingDate: _selectedDay,
      timeSlot: _selectedTimeSlot!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    context.read<FacilityProvider>().addBooking(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
} 