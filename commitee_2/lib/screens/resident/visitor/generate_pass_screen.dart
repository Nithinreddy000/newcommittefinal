import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../../providers/visitor_pass_provider.dart';
import '../../../services/auth_service.dart';
import '../../../models/visitor_pass.dart';
import '../../../mixins/form_validation_mixin.dart';

class GeneratePassScreen extends StatefulWidget {
  const GeneratePassScreen({super.key});

  @override
  State<GeneratePassScreen> createState() => _GeneratePassScreenState();
}

class _GeneratePassScreenState extends State<GeneratePassScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _purposeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _generatedQRData;
  bool _isLoading = false;
  VisitorPass? _generatedPass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Visitor Pass'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Visitor Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => validateRequired(value, 'Visitor name'),
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => validatePhone(value),
              ),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Visit*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => validateRequired(value, 'Purpose'),
              ),
              ListTile(
                title: const Text('Visit Date'),
                subtitle: Text(_selectedDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generatePass,
                child: const Text('Generate Pass'),
              ),
              if (_generatedQRData != null) ...[
                const SizedBox(height: 20),
                QrImageView(
                  data: _generatedQRData!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _shareQRCode,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Pass'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePass() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = context.read<AuthService>().currentUser;
        if (currentUser == null) return;

        final pass = await context.read<VisitorPassProvider>().generatePass(
          visitorName: _nameController.text,
          contactNumber: _contactController.text,
          purpose: _purposeController.text,
          visitDate: _selectedDate,
          flatNumber: currentUser.flatNumber ?? '',
        );

        setState(() {
          _generatedPass = pass;
          _generatedQRData = jsonEncode(pass.toQRData());
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitor pass generated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate pass: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _shareQRCode() {
    // Implement sharing functionality
    // You can use packages like share_plus to share the QR code
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _purposeController.dispose();
    super.dispose();
  }
}