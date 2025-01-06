import 'package:flutter/material.dart';

class FacilityBooking {
  final String id;
  final String facilityId;
  final String facilityName;
  final String residentId;
  final String residentName;
  final DateTime bookingDate;
  final TimeSlot timeSlot;
  final BookingStatus status;

  FacilityBooking({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.residentId,
    required this.residentName,
    required this.bookingDate,
    required this.timeSlot,
    this.status = BookingStatus.pending,
  });
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() {
    String _formatTime(TimeOfDay time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }
}

enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled
} 