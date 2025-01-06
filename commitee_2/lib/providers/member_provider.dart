import 'package:flutter/foundation.dart';
import '../models/member.dart';

class MemberProvider extends ChangeNotifier {
  final List<Member> _members = [];

  List<Member> get members => _members;

  Future<void> addMember({
    required String name,
    required String email,
    String? flatNumber,
    String? idNumber,
    required String contactNumber,
    String role = 'resident',
  }) async {
    final member = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      flatNumber: flatNumber,
      idNumber: idNumber,
      contactNumber: contactNumber,
      role: role,
    );
    _members.add(member);
    notifyListeners();
  }

  void removeMember(String id) {
    _members.removeWhere((member) => member.id == id);
    notifyListeners();
  }
} 