import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({Key? key}) : super(key: key);

  @override
  _CreateAnnouncementScreenState createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Announcement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                hintText: 'Title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contentController,
                hintText: 'Content',
                prefixIcon: Icons.content_paste,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createAnnouncement,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _apiService.createAnnouncement(
          _titleController.text,
          _contentController.text,
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating announcement: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}

