import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/visitor_provider.dart';
import '../../../services/auth_service.dart';
import '../../../models/visitor.dart';

class ResidentVisitorLogScreen extends StatelessWidget {
  const ResidentVisitorLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flatNumber = context.read<AuthService>().currentUser?.flatNumber ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Visitors'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Current Visitors'),
              Tab(text: 'Past Visitors'),
            ],
          ),
        ),
        body: Consumer<VisitorProvider>(
          builder: (context, provider, child) {
            final activeVisitors = provider.activeVisitors
                .where((v) => v.flatNumber == flatNumber)
                .toList();
            final pastVisitors = provider.completedVisits
                .where((v) => v.flatNumber == flatNumber)
                .toList();

            return TabBarView(
              children: [
                _buildVisitorList(activeVisitors, true),
                _buildVisitorList(pastVisitors, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisitorList(List<Visitor> visitors, bool isActive) {
    if (visitors.isEmpty) {
      return Center(
        child: Text(
          isActive ? 'No current visitors' : 'No past visitors',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isActive ? Colors.green : Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(visitor.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Purpose: ${visitor.purpose}'),
                Text('Contact: ${visitor.contactNumber}'),
                if (visitor.vehicleNumber.isNotEmpty)
                  Text('Vehicle: ${visitor.vehicleNumber}'),
                Text(
                  'Entry: ${_formatDateTime(visitor.entryTime)}',
                ),
                if (visitor.exitTime != null)
                  Text(
                    'Exit: ${_formatDateTime(visitor.exitTime!)}',
                  ),
                Text(
                  'Approved by: ${visitor.approvedBy}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 