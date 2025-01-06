import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';

class SecurityDashboard extends StatelessWidget {
  const SecurityDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Security Dashboard'),
      drawer: const CustomDrawer(),
      body: Center(
        child: Text(
          'Welcome to the Security Dashboard',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}

