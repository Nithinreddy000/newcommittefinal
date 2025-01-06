import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../models/payment_transaction.dart';
import '../../../services/auth_service.dart';

class PaymentPortalScreen extends StatelessWidget {
  const PaymentPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flatNumber = context.read<AuthService>().currentUser?.flatNumber ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Portal'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: Consumer<PaymentProvider>(
          builder: (context, provider, child) {
            final pendingPayments = provider.pendingTransactions
                .where((t) => t.flatNumber == flatNumber)
                .toList();
            final completedPayments = provider.completedTransactions
                .where((t) => t.flatNumber == flatNumber)
                .toList();

            return TabBarView(
              children: [
                _buildPaymentList(pendingPayments, true, context),
                _buildPaymentList(completedPayments, false, context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentList(List<PaymentTransaction> transactions, bool isPending, BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'No pending payments' : 'No payment history',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(transaction.status),
              child: Icon(
                _getStatusIcon(transaction.status),
                color: Colors.white,
              ),
            ),
            title: Text('₹${transaction.amount} - ${transaction.description}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due Date: ${_formatDate(transaction.dueDate)}'),
                if (transaction.paidDate != null)
                  Text('Paid on: ${_formatDate(transaction.paidDate!)}'),
                Text(
                  'Status: ${transaction.status.name.toUpperCase()}',
                  style: TextStyle(
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: isPending
                ? ElevatedButton(
                    onPressed: () => _showPaymentDialog(context, transaction),
                    child: const Text('Pay Now'),
                  )
                : null,
            isThreeLine: true,
          ),
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context, PaymentTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${transaction.amount}'),
            Text('Description: ${transaction.description}'),
            const SizedBox(height: 16),
            const Text('Choose payment method:'),
            const SizedBox(height: 8),
            _buildPaymentMethodButton(
              context,
              'UPI',
              Icons.payment,
              transaction,
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodButton(
              context,
              'Card',
              Icons.credit_card,
              transaction,
            ),
            const SizedBox(height: 8),
            _buildPaymentMethodButton(
              context,
              'Net Banking',
              Icons.account_balance,
              transaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(
    BuildContext context,
    String method,
    IconData icon,
    PaymentTransaction transaction,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          _processPayment(context, method, transaction);
        },
        icon: Icon(icon),
        label: Text(method),
      ),
    );
  }

  void _processPayment(BuildContext context, String method, PaymentTransaction transaction) {
    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      context.read<PaymentProvider>().updateTransactionStatus(
            transaction.id,
            PaymentStatus.completed,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful via $method'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.overdue:
        return Colors.red.shade900;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.pending;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.overdue:
        return Icons.warning;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 