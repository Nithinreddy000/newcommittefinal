import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/visitor_provider.dart';

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
                      Text('Status: ${visitor.status}'),
                    ],
                  ),
                  trailing: visitor.status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => provider.approveVisitor(visitor.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => provider.rejectVisitor(visitor.id),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
} 