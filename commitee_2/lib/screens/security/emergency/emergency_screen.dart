import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  final List<Map<String, String>> emergencyContacts = [
    {
      'title': 'Police',
      'number': '100',
      'icon': 'police_car',
    },
    {
      'title': 'Fire Department',
      'number': '101',
      'icon': 'fire_truck',
    },
    {
      'title': 'Ambulance',
      'number': '102',
      'icon': 'ambulance',
    },
    {
      'title': 'Society Manager',
      'number': '+91 98765 43210',
      'icon': 'person',
    },
  ];

  EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  _getIcon(contact['icon']!),
                  color: Colors.white,
                ),
              ),
              title: Text(contact['title']!),
              subtitle: Text(contact['number']!),
              trailing: IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // TODO: Implement phone call
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${contact['title']}...'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Report Emergency'),
              content: const TextField(
                decoration: InputDecoration(
                  labelText: 'Emergency Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency reported successfully'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Report'),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning),
      ),
    );
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'police_car':
        return Icons.local_police;
      case 'fire_truck':
        return Icons.local_fire_department;
      case 'ambulance':
        return Icons.medical_services;
      case 'person':
        return Icons.person;
      default:
        return Icons.emergency;
    }
  }
} 