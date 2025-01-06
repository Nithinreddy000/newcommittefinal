import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Smart Community'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, User!',
              style: Theme.of(context).textTheme.headline1,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                CustomCard(title: 'Announcements', icon: Icons.announcement),
                CustomCard(title: 'Payments', icon: Icons.payment),
                CustomCard(title: 'Facilities', icon: Icons.room),
                CustomCard(title: 'Complaints', icon: Icons.report_problem),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

