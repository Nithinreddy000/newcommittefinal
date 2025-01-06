import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Payment>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = _apiService.getPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Payments'),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _paymentsFuture = _apiService.getPayments();
          });
        },
        child: FutureBuilder<List<Payment>>(
          future: _paymentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No payments available.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final payment = snapshot.data![index];
                  return PaymentCard(
                    payment: payment,
                    onPaymentMade: () {
                      setState(() {
                        _paymentsFuture = _apiService.getPayments();
                      });
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onPaymentMade;

  const PaymentCard({Key? key, required this.payment, required this.onPaymentMade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(payment.description),
        subtitle: Text('Due: ${payment.dueDate.toLocal().toString().split(' ')[0]}'),
        trailing: payment.isPaid
            ? const Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: () => _makePayment(context),
                child: const Text('Pay'),
              ),
      ),
    );
  }

  void _makePayment(BuildContext context) async {
    final apiService = ApiService();
    try {
      await apiService.makePayment(payment.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful')),
      );
      onPaymentMade();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making payment: $e')),
      );
    }
  }
}

