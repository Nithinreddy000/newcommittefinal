import 'package:flutter/foundation.dart';
import '../models/payment_transaction.dart';

class PaymentProvider extends ChangeNotifier {
  final List<PaymentTransaction> _transactions = [];

  List<PaymentTransaction> get transactions => _transactions;
  List<PaymentTransaction> get pendingTransactions => 
      _transactions.where((t) => t.status == PaymentStatus.pending).toList();
  List<PaymentTransaction> get completedTransactions => 
      _transactions.where((t) => t.status == PaymentStatus.completed).toList();

  void addTransaction(PaymentTransaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransactionStatus(String id, PaymentStatus status) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = PaymentTransaction(
        id: _transactions[index].id,
        userId: _transactions[index].userId,
        flatNumber: _transactions[index].flatNumber,
        amount: _transactions[index].amount,
        dueDate: _transactions[index].dueDate,
        paidDate: status == PaymentStatus.completed ? DateTime.now() : null,
        description: _transactions[index].description,
        status: status,
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      notifyListeners();
    }
  }
} 