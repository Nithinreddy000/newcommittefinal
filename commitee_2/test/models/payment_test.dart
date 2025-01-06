import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/models/payment.dart';

void main() {
  group('Payment', () {
    test('should create a Payment instance from JSON', () {
      final json = {
        'id': '1',
        'amount': 100.0,
        'description': 'Monthly maintenance fee',
        'dueDate': '2023-05-31T00:00:00Z',
        'isPaid': false,
      };

      final payment = Payment.fromJson(json);

      expect(payment.id, '1');
      expect(payment.amount, 100.0);
      expect(payment.description, 'Monthly maintenance fee');
      expect(payment.dueDate, DateTime.parse('2023-05-31T00:00:00Z'));
      expect(payment.isPaid, false);
    });

    test('should convert Payment instance to JSON', () {
      final payment = Payment(
        id: '1',
        amount: 100.0,
        description: 'Monthly maintenance fee',
        dueDate: DateTime.parse('2023-05-31T00:00:00Z'),
        isPaid: false,
      );

      final json = payment.toJson();

      expect(json['id'], '1');
      expect(json['amount'], 100.0);
      expect(json['description'], 'Monthly maintenance fee');
      expect(json['dueDate'], '2023-05-31T00:00:00.000Z');
      expect(json['isPaid'], false);
    });
  });
}

