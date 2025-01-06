import 'package:flutter/foundation.dart';
import '../models/visitor_pass.dart';

class VisitorPassProvider extends ChangeNotifier {
  final List<VisitorPass> _passes = [];

  List<VisitorPass> get passes => _passes;

  List<VisitorPass> getPassesByFlat(String flatNumber) {
    return _passes.where((pass) => pass.flatNumber == flatNumber).toList();
  }

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
    );

    _passes.add(pass);
    notifyListeners();
    return pass;
  }

  void updatePass(VisitorPass updatedPass) {
    final index = _passes.indexWhere((pass) => pass.id == updatedPass.id);
    if (index != -1) {
      _passes[index] = updatedPass;
      notifyListeners();
    }
  }

  List<VisitorPass> getValidPasses() {
    return _passes.where((pass) => !pass.isUsed && pass.visitDate.isAfter(DateTime.now())).toList();
  }

  Future<bool> verifyPass(String passId) async {
    final index = _passes.indexWhere((pass) => pass.id == passId);
    if (index != -1) {
      final pass = _passes[index];
      if (!pass.isUsed && pass.visitDate.isAfter(DateTime.now())) {
        _passes[index] = VisitorPass(
          id: pass.id,
          visitorName: pass.visitorName,
          contactNumber: pass.contactNumber,
          purpose: pass.purpose,
          visitDate: pass.visitDate,
          flatNumber: pass.flatNumber,
          isUsed: true,
          status: VisitorPassStatus.approved,
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }
} 