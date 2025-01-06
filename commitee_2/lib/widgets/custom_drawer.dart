import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/payments_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.name[0],
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  user.role.toString().split('.').last,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Announcements'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to announcements screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.room),
            title: const Text('Facilities'),
            onTap: () {
              // Navigate to facilities
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Complaints'),
            onTap: () {
              // Navigate to complaints
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}

