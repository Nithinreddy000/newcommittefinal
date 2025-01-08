import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/facility.dart';
import '../../../models/facility_booking.dart';
import '../../../providers/facility_provider.dart';
import '../../../services/auth_service.dart';

class FacilityBookingScreen extends StatefulWidget {
  final Facility facility;
  final FacilityBooking? booking;
  final bool isEditing;

  const FacilityBookingScreen({
    Key? key,
    required this.facility,
    this.booking,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<FacilityBookingScreen> createState() => _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends State<FacilityBookingScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  TimeSlot? _selectedTimeSlot;
  final _notesController = TextEditingController();
  final _purposeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _selectedDay = widget.booking!.date;
      _focusedDay = widget.booking!.date;
      _selectedTimeSlot = widget.booking!.timeSlot;
      _purposeController.text = widget.booking!.purpose;
      _notesController.text = widget.booking!.notes;
    } else {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.isEditing ? 'Edit' : 'Book'} ${widget.facility.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Facility Image and Details
            Card(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.facility.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.facility.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a time slot to book this facility',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Calendar
            Card(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTimeSlot = null; // Reset time slot when date changes
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Time Slots
            Text(
              'Select Time Slot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<FacilityProvider>(
              builder: (context, provider, child) {
                final availableSlots = provider.getAvailableTimeSlots(
                  widget.facility.id,
                  _selectedDay,
                );

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TimeSlot.values.map((slot) {
                    final isAvailable = availableSlots.contains(slot);
                    return ChoiceChip(
                      label: Text(_formatTimeSlot(slot)),
                      selected: _selectedTimeSlot == slot,
                      onSelected: isAvailable
                          ? (selected) {
                              setState(() {
                                _selectedTimeSlot = selected ? slot : null;
                              });
                            }
                          : null,
                      backgroundColor:
                          isAvailable ? null : Colors.grey.withOpacity(0.3),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Purpose
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose of Booking',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook ? _handleSubmit : null,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(widget.isEditing ? 'Update Booking' : 'Book Facility'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canBook {
    return !_isLoading &&
        _selectedTimeSlot != null &&
        _purposeController.text.isNotEmpty;
  }

  String _formatTimeSlot(TimeSlot slot) {
    return '${slot.startTime} - ${slot.endTime}';
  }

  Future<void> _handleSubmit() async {
    if (_selectedTimeSlot == null) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<FacilityProvider>(context, listen: false);
      final user = Provider.of<AuthService>(context, listen: false).currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      if (widget.isEditing && widget.booking != null) {
        await provider.updateBooking(
          bookingId: widget.booking!.id,
          date: _selectedDay,
          timeSlot: _selectedTimeSlot!,
          purpose: _purposeController.text,
          notes: _notesController.text,
        );
      } else {
        await provider.bookFacility(
          facilityId: widget.facility.id,
          userId: user.id,
          userName: user.name,
          date: _selectedDay,
          timeSlot: _selectedTimeSlot!,
          purpose: _purposeController.text,
          notes: _notesController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Booking updated successfully'
                : 'Facility booked successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Failed to update booking: ${e.toString()}'
                  : 'Failed to book facility: ${e.toString()}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}