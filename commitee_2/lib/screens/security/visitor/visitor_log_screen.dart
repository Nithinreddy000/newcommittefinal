import 'package:flutter/material.dart';
import '../../../models/visitor.dart';
import '../../../providers/visitor_provider.dart';
import 'package:provider/provider.dart';

class VisitorLogScreen extends StatelessWidget {
  VisitorLogScreen({super.key});

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
                _buildVisitorList(provider.activeVisitors, true),
                _buildVisitorList(provider.completedVisits, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVisitorList(List<Visitor> visitors, bool showExitButton) {
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
                Text('Entry: ${visitor.entryTime.toString().split('.')[0]}'),
                if (visitor.exitTime != null)
                  Text('Exit: ${visitor.exitTime.toString().split('.')[0]}'),
              ],
            ),
            trailing: showExitButton
                ? ElevatedButton(
                    onPressed: () {
                      context.read<VisitorProvider>().recordExit(visitor.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exit recorded successfully'),
                        ),
                      );
                    },
                    child: const Text('Record Exit'),
                  )
                : const Icon(Icons.check_circle, color: Colors.green),
            isThreeLine: true,
          ),
        );
      },
    );
  }
} 