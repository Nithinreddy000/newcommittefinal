import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visitor_provider.dart';
import '../../models/visitor.dart';

class VisitorManagementScreen extends StatelessWidget {
  const VisitorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<VisitorProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.visitors.length,
            itemBuilder: (context, index) {
              final visitor = provider.visitors[index];
              return Card(
                child: ListTile(
                  title: Text(visitor.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Purpose: ${visitor.purpose}'),
                      Text('Flat: ${visitor.flatNumber}'),
                      Text('Contact: ${visitor.contactNumber}'),
                      if (visitor.vehicleNumber.isNotEmpty)
                        Text('Vehicle: ${visitor.vehicleNumber}'),
                      Text('Status: ${visitor.status}'),
                      if (visitor.entryTime != null)
                        Text('Entry: ${visitor.entryTime.toString().split('.')[0]}'),
                      if (visitor.exitTime != null)
                        Text('Exit: ${visitor.exitTime.toString().split('.')[0]}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (visitor.status == 'pending') ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => provider.approveVisitor(visitor.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => provider.rejectVisitor(visitor.id),
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(context, visitor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => _showDeleteDialog(context, provider, visitor.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Visitor visitor) {
    final nameController = TextEditingController(text: visitor.name);
    final purposeController = TextEditingController(text: visitor.purpose);
    final flatController = TextEditingController(text: visitor.flatNumber);
    final contactController = TextEditingController(text: visitor.contactNumber);
    final vehicleController = TextEditingController(text: visitor.vehicleNumber);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Visitor Log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Visitor Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: flatController,
                decoration: const InputDecoration(
                  labelText: 'Flat Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedVisitor = visitor.copyWith(
                name: nameController.text.trim(),
                purpose: purposeController.text.trim(),
                contactNumber: contactController.text.trim(),
                flatNumber: flatController.text.trim(),
                vehicleNumber: vehicleController.text.trim(),
              );
              context.read<VisitorProvider>().updateVisitor(updatedVisitor);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visitor log updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VisitorProvider provider, String visitorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Visitor Log'),
        content: const Text('Are you sure you want to delete this visitor log? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteVisitor(visitorId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visitor log deleted successfully'),
                  backgroundColor: Colors.red,
                ),
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
  }
}