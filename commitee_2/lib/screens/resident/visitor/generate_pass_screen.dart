import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/visitor_pass.dart';
import '../../../providers/visitor_pass_provider.dart';
import '../../../services/auth_service.dart';
import '../../../mixins/form_validation_mixin.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GeneratePassScreen extends StatefulWidget {
  final VisitorPass? pass;
  const GeneratePassScreen({Key? key, this.pass}) : super(key: key);

  @override
  _GeneratePassScreenState createState() => _GeneratePassScreenState();
}

class _GeneratePassScreenState extends State<GeneratePassScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _visitorNameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _purposeController;
  late DateTime _selectedDate;
  String? _generatedQRData;
  bool _isLoading = false;
  VisitorPass? _generatedPass;

  @override
  void initState() {
    super.initState();
    _visitorNameController = TextEditingController(text: widget.pass?.visitorName ?? '');
    _contactNumberController = TextEditingController(text: widget.pass?.contactNumber ?? '');
    _purposeController = TextEditingController(text: widget.pass?.purpose ?? '');
    _selectedDate = widget.pass?.visitDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _visitorNameController.dispose();
    _contactNumberController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<VisitorPassProvider>(context, listen: false);
        final userProvider = Provider.of<AuthService>(context, listen: false);
        
        if (widget.pass != null) {
          // Update existing pass
          await provider.updatePass(
            widget.pass!.id,
            visitorName: _visitorNameController.text,
            contactNumber: _contactNumberController.text,
            purpose: _purposeController.text,
            visitDate: _selectedDate,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visitor pass updated successfully')),
          );
          Navigator.pop(context);
        } else {
          // Create new pass
          final pass = await provider.generatePass(
            visitorName: _visitorNameController.text,
            contactNumber: _contactNumberController.text,
            purpose: _purposeController.text,
            visitDate: _selectedDate,
            flatNumber: userProvider.currentUser?.flatNumber ?? '',
          );
          setState(() {
            _generatedPass = pass;
            _generatedQRData = jsonEncode(pass.toQRData());
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visitor pass generated successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pass != null ? 'Edit Visitor Pass' : 'Generate Visitor Pass'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _visitorNameController,
                decoration: const InputDecoration(labelText: 'Visitor Name*'),
                validator: (value) => validateRequired(value, 'Visitor name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(labelText: 'Contact Number*'),
                keyboardType: TextInputType.phone,
                validator: (value) => validatePhone(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(labelText: 'Purpose of Visit*'),
                validator: (value) => validateRequired(value, 'Purpose'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Visit Date'),
                subtitle: Text(_selectedDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(widget.pass != null ? 'Update Pass' : 'Generate Pass'),
                ),
              if (_generatedPass != null) ...[
                const SizedBox(height: 20),
                QrImageView(
                  data: _generatedQRData!,
                  version: QrVersions.auto,
                  size: 200,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Share functionality
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share Pass'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeneratePassScreen(
                              pass: _generatedPass,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Pass'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Pass'),
                            content: const Text('Are you sure you want to delete this visitor pass?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final provider = Provider.of<VisitorPassProvider>(context, listen: false);
                                  provider.deletePass(_generatedPass!.id);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Visitor pass deleted')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Pass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}