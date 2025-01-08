import 'package:flutter/foundation.dart';
import '../models/facility.dart';
import '../models/facility_booking.dart';

class FacilityProvider with ChangeNotifier {
  final List<Facility> _facilities = [];
  final List<FacilityBooking> _bookings = [];

  List<Facility> get facilities => List.unmodifiable(_facilities);
  List<FacilityBooking> get bookings => List.unmodifiable(_bookings);

  void addFacility({
    required String name,
    required String description,
  }) {
    final facility = Facility(
      id: DateTime.now().toString(),
      name: name,
      description: description,
    );
    _facilities.add(facility);
    notifyListeners();
  }

  void updateFacility(Facility facility) {
    final index = _facilities.indexWhere((f) => f.id == facility.id);
    if (index != -1) {
      _facilities[index] = facility;
      notifyListeners();
    }
  }

  void removeFacility(String id) {
    _facilities.removeWhere((facility) => facility.id == id);
    notifyListeners();
  }

  Facility? getFacility(String id) {
    try {
      return _facilities.firstWhere((facility) => facility.id == id);
    } catch (e) {
      return null;
    }
  }

  List<TimeSlot> getAvailableTimeSlots(String facilityId, DateTime date) {
    final facility = getFacility(facilityId);
    if (facility == null) return [];

    final facilityBookings = _bookings.where(
      (booking) =>
          booking.facilityId == facilityId &&
          booking.date.year == date.year &&
          booking.date.month == date.month &&
          booking.date.day == date.day &&
          (booking.status == BookingStatus.approved || booking.status == BookingStatus.pending),
    );

    return TimeSlot.values.where((slot) {
      return !facilityBookings.any((booking) => booking.timeSlot == slot);
    }).toList();
  }

  Future<void> bookFacility({
    required String facilityId,
    required String userId,
    required String userName,
    required DateTime date,
    required TimeSlot timeSlot,
    required String purpose,
    String notes = '',
  }) async {
    // Validate facility exists
    final facility = getFacility(facilityId);
    if (facility == null) {
      throw Exception('Facility not found');
    }

    // Check if slot is available
    final availableSlots = getAvailableTimeSlots(facilityId, date);
    if (!availableSlots.contains(timeSlot)) {
      throw Exception('Time slot is not available');
    }

    final booking = FacilityBooking(
      id: DateTime.now().toString(),
      facilityId: facilityId,
      userId: userId,
      userName: userName,
      date: date,
      timeSlot: timeSlot,
      purpose: purpose,
      notes: notes,
    );

    _bookings.add(booking);
    notifyListeners();
  }

  List<FacilityBooking> getUserBookings(String userId) {
    return _bookings
        .where((booking) => booking.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      throw Exception('Booking not found');
    }

    _bookings[index] = _bookings[index].copyWith(status: status);
    notifyListeners();
  }

  Future<void> cancelBooking(String bookingId) async {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      throw Exception('Booking not found');
    }

    if (_bookings[index].status != BookingStatus.pending && 
        _bookings[index].status != BookingStatus.approved) {
      throw Exception('Cannot cancel booking with status: ${_bookings[index].status}');
    }

    _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
    notifyListeners();
  }

  Future<void> updateBooking({
    required String bookingId,
    required DateTime date,
    required TimeSlot timeSlot,
    required String purpose,
    String notes = '',
  }) async {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      throw Exception('Booking not found');
    }

    final booking = _bookings[index];
    
    // Check if the new time slot is available (excluding the current booking)
    final facilityBookings = _bookings.where(
      (b) =>
          b.facilityId == booking.facilityId &&
          b.id != bookingId &&
          b.date.year == date.year &&
          b.date.month == date.month &&
          b.date.day == date.day &&
          b.timeSlot == timeSlot &&
          (b.status == BookingStatus.approved || b.status == BookingStatus.pending),
    );

    if (facilityBookings.isNotEmpty) {
      throw Exception('Time slot is not available');
    }

    _bookings[index] = booking.copyWith(
      date: date,
      timeSlot: timeSlot,
      purpose: purpose,
      notes: notes,
    );
    
    notifyListeners();
  }
}