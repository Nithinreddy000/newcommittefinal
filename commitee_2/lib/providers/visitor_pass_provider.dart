import 'package:flutter/foundation.dart';
import '../models/visitor_pass.dart';

class VisitorPassProvider extends ChangeNotifier {
  final List<VisitorPass> _passes = [];

  List<VisitorPass> get passes => _passes;

  Future<VisitorPass> generatePass({
    required String visitorName,
    required String contactNumber,
    required String purpose,
    required DateTime visitDate,
    required String flatNumber,
  }) async {
    final pass = VisitorPass(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      visitorName: visitorName,
      contactNumber: contactNumber,
      purpose: purpose,
      visitDate: visitDate,
      flatNumber: flatNumber,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    _passes.add(pass);
    notifyListeners();
    return pass;
  }

  Future<VisitorPass> updatePass(
    String passId, {
    String? visitorName,
    String? contactNumber,
    String? purpose,
    DateTime? visitDate,
  }) async {
    final index = _passes.indexWhere((p) => p.id == passId);
    if (index == -1) {
      throw Exception('Pass not found');
    }

    final pass = _passes[index];
    final updatedPass = pass.copyWith(
      visitorName: visitorName,
      contactNumber: contactNumber,
      purpose: purpose,
      visitDate: visitDate,
      lastUpdated: DateTime.now(),
    );

    _passes[index] = updatedPass;
    notifyListeners();
    return updatedPass;
  }

  void deletePass(String passId) {
    _passes.removeWhere((p) => p.id == passId);
    notifyListeners();
  }

  List<VisitorPass> getValidPasses() {
    return _passes.where((pass) => !pass.isUsed && pass.visitDate.isAfter(DateTime.now())).toList();
  }

  Future<bool> verifyPass(String passId) async {
    final index = _passes.indexWhere((pass) => pass.id == passId);
    if (index != -1) {
      final pass = _passes[index];
      if (!pass.isUsed && pass.visitDate.isAfter(DateTime.now())) {
        _passes[index] = pass.copyWith(
          isUsed: true,
          status: 'approved',
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void approvePass(String passId) {
    final index = _passes.indexWhere((p) => p.id == passId);
    if (index != -1) {
      _passes[index] = _passes[index].copyWith(
        status: 'approved',
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void rejectPass(String passId) {
    final index = _passes.indexWhere((p) => p.id == passId);
    if (index != -1) {
      _passes[index] = _passes[index].copyWith(
        status: 'rejected',
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  List<VisitorPass> getActivePassesByFlat(String flatNumber) {
    final now = DateTime.now();
    return _passes.where((pass) => 
      pass.flatNumber == flatNumber && 
      pass.visitDate.isAfter(now) &&
      pass.status != 'cancelled'
    ).toList();
  }

  List<VisitorPass> getPastPassesByFlat(String flatNumber) {
    final now = DateTime.now();
    return _passes.where((pass) => 
      pass.flatNumber == flatNumber && 
      (pass.visitDate.isBefore(now) || pass.status == 'cancelled')
    ).toList();
  }
}