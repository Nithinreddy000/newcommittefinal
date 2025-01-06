enum TimeSlot { morning, afternoon, evening }

enum BookingStatus { pending, approved, rejected, cancelled }

class FacilityBooking {
  final String id;
  final String userId;
  final String facilityId;
  final String facilityName;
  final DateTime bookingDate;
  final TimeSlot timeSlot;
  final BookingStatus status;
  final String? notes;

  FacilityBooking({
    required this.id,
    required this.userId,
    required this.facilityId,
    required this.facilityName,
    required this.bookingDate,
    required this.timeSlot,
    this.status = BookingStatus.pending,
    this.notes,
  });
} 