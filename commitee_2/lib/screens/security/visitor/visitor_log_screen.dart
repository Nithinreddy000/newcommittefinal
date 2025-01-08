import 'package:flutter/material.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_provider.dart';
import 'package:provider/provider.dart';

class VisitorLogScreen extends StatelessWidget {
  const VisitorLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Visitor Log'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Visitors'),
              Tab(text: 'Completed Visits'),
            ],
          ),
        ),
        body: Consumer<VisitorProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildVisitorList(context, provider.activeVisitors, true),
                _buildVisitorList(context, provider.completedVisits, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisitorList(BuildContext context, List<Visitor> visitors, bool showExitButton) {
    return ListView.builder(
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(visitor.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flat: ${visitor.flatNumber}'),
                Text('Purpose: ${visitor.purpose}'),
                Text('Contact: ${visitor.contactNumber}'),
                if (visitor.vehicleNumber.isNotEmpty)
                  Text('Vehicle: ${visitor.vehicleNumber}'),
                Text('Entry: ${visitor.entryTime.toString().split('.')[0]}'),
                if (visitor.exitTime != null)
                  Text('Exit: ${visitor.exitTime.toString().split('.')[0]}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showExitButton && visitor.exitTime == null)
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => context.read<VisitorProvider>().markVisitorExit(visitor.id),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, visitor),
                ),
              ],
            ),
          ),
        );
      },
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
}