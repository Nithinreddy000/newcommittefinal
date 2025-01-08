enum TimeSlot {
  slot_8_9('8:00 AM', '9:00 AM'),
  slot_9_10('9:00 AM', '10:00 AM'),
  slot_10_11('10:00 AM', '11:00 AM'),
  slot_11_12('11:00 AM', '12:00 PM'),
  slot_12_13('12:00 PM', '1:00 PM'),
  slot_13_14('1:00 PM', '2:00 PM'),
  slot_14_15('2:00 PM', '3:00 PM'),
  slot_15_16('3:00 PM', '4:00 PM'),
  slot_16_17('4:00 PM', '5:00 PM'),
  slot_17_18('5:00 PM', '6:00 PM'),
  slot_18_19('6:00 PM', '7:00 PM'),
  slot_19_20('7:00 PM', '8:00 PM');

  final String startTime;
  final String endTime;

  const TimeSlot(this.startTime, this.endTime);
}

enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled
}

class FacilityBooking {
  final String id;
  final String facilityId;
  final String userId;
  final String userName;
  final DateTime date;
  final TimeSlot timeSlot;
  final String notes;
  final String purpose;
  final BookingStatus status;
  final DateTime startTime;
  final DateTime endTime;

  FacilityBooking({
    required this.id,
    required this.facilityId,
    required this.userId,
    required this.userName,
    required this.date,
    required this.timeSlot,
    required this.notes,
    required this.purpose,
    this.status = BookingStatus.pending,
    DateTime? startTime,
    DateTime? endTime,
  }) : startTime = startTime ?? date,
       endTime = endTime ?? date.add(const Duration(hours: 1));

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityId': facilityId,
      'userId': userId,
      'userName': userName,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot.toString(),
      'notes': notes,
      'purpose': purpose,
      'status': status.toString(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory FacilityBooking.fromJson(Map<String, dynamic> json) {
    return FacilityBooking(
      id: json['id'],
      facilityId: json['facilityId'],
      userId: json['userId'],
      userName: json['userName'],
      date: DateTime.parse(json['date']),
      timeSlot: TimeSlot.values.firstWhere(
        (slot) => slot.toString() == json['timeSlot'],
      ),
      notes: json['notes'],
      purpose: json['purpose'],
      status: BookingStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
      ),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  FacilityBooking copyWith({
    String? id,
    String? facilityId,
    String? userId,
    String? userName,
    DateTime? date,
    TimeSlot? timeSlot,
    String? notes,
    String? purpose,
    BookingStatus? status,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return FacilityBooking(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      notes: notes ?? this.notes,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
