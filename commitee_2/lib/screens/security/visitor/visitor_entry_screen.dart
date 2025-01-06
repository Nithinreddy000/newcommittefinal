import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_provider.dart';
import '../../../services/auth_service.dart';
import 'qr_scanner_screen.dart';

class VisitorEntryScreen extends StatefulWidget {
  const VisitorEntryScreen({super.key});

  @override
  State<VisitorEntryScreen> createState() => _VisitorEntryScreenState();
}

class _VisitorEntryScreenState extends State<VisitorEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _flatController = TextEditingController();
  final _contactController = TextEditingController();
  final _vehicleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Visitor Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter visitor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Visit',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter purpose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flatController,
                decoration: const InputDecoration(
                  labelText: 'Flat Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter flat number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Record Entry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QRScannerScreen(),
          ),
        ),
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      final visitor = Visitor(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        purpose: _purposeController.text,
        flatNumber: _flatController.text,
        entryTime: DateTime.now(),
        contactNumber: _contactController.text,
        vehicleNumber: _vehicleController.text,
        approvedBy: context.read<AuthService>().currentUser?.name ?? 'Security',
      );

      context.read<VisitorProvider>().addVisitor(visitor);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor entry recorded successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _flatController.dispose();
    _contactController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }
} 