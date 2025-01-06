import 'package:flutter/foundation.dart';
import '../models/facility.dart';
import '../models/facility_booking_new.dart';

class FacilityProvider extends ChangeNotifier {
  final List<Facility> _facilities = [
    Facility(id: '1', name: 'Swimming Pool', description: 'Olympic size swimming pool', icon: 'pool'),
    Facility(id: '2', name: 'Gym', description: 'Fully equipped fitness center', icon: 'fitness'),
    Facility(id: '3', name: 'Community Hall', description: 'Multi-purpose community hall', icon: 'hall'),
  ];

  final List<FacilityBooking> _bookings = [];

  List<Facility> get facilities => _facilities;
  List<FacilityBooking> get bookings => _bookings;

  void addFacility(Facility facility) {
    _facilities.add(facility);
    notifyListeners();
  }

  void addBooking(FacilityBooking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void approveBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = FacilityBooking(
        id: _bookings[index].id,
        facilityId: _bookings[index].facilityId,
        userId: _bookings[index].userId,
        facilityName: _bookings[index].facilityName,
        bookingDate: _bookings[index].bookingDate,
        timeSlot: _bookings[index].timeSlot,
        status: BookingStatus.approved,
        notes: _bookings[index].notes,
      );
      notifyListeners();
    }
  }

  List<FacilityBooking> getBookingsByUser(String userId) {
    return _bookings.where((booking) => booking.userId == userId).toList();
  }

  List<FacilityBooking> getBookingsByFacility(String facilityId) {
    return _bookings.where((booking) => booking.facilityId == facilityId).toList();
  }
} 