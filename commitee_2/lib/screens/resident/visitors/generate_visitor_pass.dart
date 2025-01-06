import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/visitor.dart';

class GenerateVisitorPass extends StatefulWidget {
  const GenerateVisitorPass({super.key});

  @override
  State<GenerateVisitorPass> createState() => _GenerateVisitorPassState();
}

class _GenerateVisitorPassState extends State<GenerateVisitorPass> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _contactController = TextEditingController();
  String? _generatedQR;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Visitor Pass'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_generatedQR != null) ...[
                QrImageView(
                  data: _generatedQR!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 16),
                Text(
                  'Share this QR code with your visitor',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _generatedQR = null;
                    });
                  },
                  child: const Text('Generate New Pass'),
                ),
              ] else ...[
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _generateQRCode,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Generate QR Code'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _generateQRCode() {
    if (_formKey.currentState!.validate()) {
      final visitorData = {
        'name': _nameController.text,
        'purpose': _purposeController.text,
        'contact': _contactController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _generatedQR = Uri.encodeFull(visitorData.toString());
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _contactController.dispose();
    super.dispose();
  }
} 