import 'package:flutter/foundation.dart';
import '../models/visitor.dart';

class VisitorProvider extends ChangeNotifier {
  final List<Visitor> _visitors = [];

  List<Visitor> get visitors => _visitors;
  List<Visitor> get activeVisitors => _visitors.where((v) => v.isInside).toList();
  List<Visitor> get completedVisits => _visitors.where((v) => !v.isInside).toList();

  void addVisitor(Visitor visitor) {
    _visitors.add(visitor);
    notifyListeners();
  }

  void updateVisitor(Visitor updatedVisitor) {
    final index = _visitors.indexWhere((v) => v.id == updatedVisitor.id);
    if (index != -1) {
      _visitors[index] = updatedVisitor;
      notifyListeners();
    }
  }

  void updateVisitorDetails(String visitorId, {
    String? name,
    String? purpose,
    String? contactNumber,
    String? vehicleNumber,
  }) {
    final index = _visitors.indexWhere((v) => v.id == visitorId);
    if (index != -1) {
      _visitors[index] = _visitors[index].copyWith(
        name: name,
        purpose: purpose,
        contactNumber: contactNumber,
        vehicleNumber: vehicleNumber,
      );
      notifyListeners();
    }
  }

  void deleteVisitor(String visitorId) {
    _visitors.removeWhere((v) => v.id == visitorId);
    notifyListeners();
  }

  void recordExit(String visitorId) {
    final index = _visitors.indexWhere((v) => v.id == visitorId);
    if (index != -1) {
      _visitors[index] = _visitors[index].copyWith(
        exitTime: DateTime.now(),
        isInside: false,
      );
      notifyListeners();
    }
  }

  void markVisitorExit(String visitorId) {
    final index = _visitors.indexWhere((v) => v.id == visitorId);
    if (index != -1) {
      final visitor = _visitors[index];
      _visitors[index] = visitor.copyWith(
        exitTime: DateTime.now(),
        status: 'completed',
        isInside: false,
      );
      notifyListeners();
    }
  }

  void approveVisitor(String id) {
    final index = _visitors.indexWhere((visitor) => visitor.id == id);
    if (index != -1) {
      _visitors[index] = _visitors[index].copyWith(status: 'approved');
      notifyListeners();
    }
  }

  void rejectVisitor(String id) {
    final index = _visitors.indexWhere((visitor) => visitor.id == id);
    if (index != -1) {
      _visitors[index] = _visitors[index].copyWith(status: 'rejected');
      notifyListeners();
    }
  }

  List<Visitor> getVisitorsByFlat(String flatNumber) {
    return _visitors.where((v) => v.flatNumber == flatNumber).toList();
  }

  List<Visitor> getActiveVisitorsByFlat(String flatNumber) {
    return activeVisitors.where((v) => v.flatNumber == flatNumber).toList();
  }

  List<Visitor> getPastVisitorsByFlat(String flatNumber) {
    return completedVisits.where((v) => v.flatNumber == flatNumber).toList();
  }
}