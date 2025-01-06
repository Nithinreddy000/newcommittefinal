import 'package:flutter/material.dart';
import '../../../models/payment.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Payment> payments = [
      Payment(
        id: '1',
        title: 'Electricity Bill - January',
        amount: 1500.00,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        type: PaymentType.electricity,
        status: PaymentStatus.pending,
        residentId: '1',
      ),
      Payment(
        id: '2',
        title: 'Water Bill - January',
        amount: 500.00,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        type: PaymentType.water,
        status: PaymentStatus.pending,
        residentId: '1',
      ),
      Payment(
        id: '3',
        title: 'Maintenance Fee - Q1',
        amount: 2000.00,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        type: PaymentType.maintenance,
        status: PaymentStatus.pending,
        residentId: '1',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: _getPaymentIcon(payment.type),
              title: Text(payment.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount: ₹${payment.amount.toStringAsFixed(2)}'),
                  Text('Due Date: ${payment.dueDate.toString().split(' ')[0]}'),
                  Text('Status: ${payment.status.name}'),
                ],
              ),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Implement payment processing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment gateway coming soon!')),
                  );
                },
                child: const Text('Pay Now'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getPaymentIcon(PaymentType type) {
    IconData iconData;
    switch (type) {
      case PaymentType.electricity:
        iconData = Icons.electric_bolt;
        break;
      case PaymentType.water:
        iconData = Icons.water_drop;
        break;
      case PaymentType.maintenance:
        iconData = Icons.build;
        break;
      case PaymentType.parkingFee:
        iconData = Icons.local_parking;
        break;
      case PaymentType.securityFee:
        iconData = Icons.security;
        break;
      case PaymentType.other:
        iconData = Icons.payment;
        break;
    }
    return Icon(iconData, size: 32);
  }
} 