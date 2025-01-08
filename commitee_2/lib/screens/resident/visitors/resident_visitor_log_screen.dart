import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_provider.dart';
import '../../../services/auth_service.dart';

class ResidentVisitorLogScreen extends StatelessWidget {
  const ResidentVisitorLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    if (user == null || user.flatNumber == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: User or flat number not found'),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Visitor Logs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Visitors'),
              Tab(text: 'Past Visitors'),
            ],
          ),
        ),
        body: Consumer<VisitorProvider>(
          builder: (context, provider, child) {
            final activeVisitors = provider.getActiveVisitorsByFlat(user.flatNumber!);
            final pastVisitors = provider.getPastVisitorsByFlat(user.flatNumber!);

            return TabBarView(
              children: [
                _buildVisitorList(activeVisitors),
                _buildVisitorList(pastVisitors),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisitorList(List<Visitor> visitors) {
    if (visitors.isEmpty) {
      return const Center(
        child: Text('No visitors found'),
      );
    }

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
                Text('Purpose: ${visitor.purpose}'),
                Text('Contact: ${visitor.contactNumber}'),
                if (visitor.vehicleNumber.isNotEmpty)
                  Text('Vehicle: ${visitor.vehicleNumber}'),
                Text('Entry: ${visitor.entryTime.toString().split('.')[0]}'),
                if (visitor.exitTime != null)
                  Text('Exit: ${visitor.exitTime.toString().split('.')[0]}'),
                Text('Status: ${visitor.status}'),
                Text('Created by: ${visitor.approvedBy}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}