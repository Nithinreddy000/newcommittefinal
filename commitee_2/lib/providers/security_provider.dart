import 'package:flutter/foundation.dart';
import '../models/security_staff.dart';

class SecurityProvider extends ChangeNotifier {
  final List<SecurityStaff> _staffList = [];

  List<SecurityStaff> get activeStaff => _staffList.where((staff) => staff.isActive).toList();

  void addStaff(SecurityStaff staff) {
    _staffList.add(staff);
    notifyListeners();
  }

  void toggleActiveStatus(String staffId) {
    final staff = _staffList.firstWhere((s) => s.id == staffId);
    staff.isActive = !staff.isActive; // Toggle active status
    notifyListeners();
  }

  void requestAssistance(String staffId) {
    // Logic to send an alert to the nearest available security staff
    // This could involve sending a notification or updating a database
    notifyListeners();
  }

  @override
  String toString() {
    return 'SecurityProvider(activeStaff: $activeStaff)';
  }

  // Other methods...
} 