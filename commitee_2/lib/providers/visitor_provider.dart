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

  void recordExit(String visitorId) {
    final index = _visitors.indexWhere((v) => v.id == visitorId);
    if (index != -1) {
      _visitors[index].exitTime = DateTime.now();
      _visitors[index].isInside = false;
      notifyListeners();
    }
  }

  void approveVisitor(String id) {
    final index = _visitors.indexWhere((visitor) => visitor.id == id);
    if (index != -1) {
      _visitors[index].status = 'approved';
      notifyListeners();
    }
  }

  void rejectVisitor(String id) {
    final index = _visitors.indexWhere((visitor) => visitor.id == id);
    if (index != -1) {
      _visitors[index].status = 'rejected';
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