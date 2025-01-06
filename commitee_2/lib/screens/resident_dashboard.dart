import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../models/announcement.dart'; // Assuming this model exists
import '../services/api_service.dart'; // Assuming this service exists

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({Key? key}) : super(key: key);

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  late Future<List<Announcement>> _announcementsFuture;
  final _apiService = ApiService(); // Assuming ApiService is defined elsewhere

  @override
  void initState() {
    super.initState();
    _announcementsFuture = _apiService.getAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Resident Dashboard'),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _announcementsFuture = _apiService.getAnnouncements();
          });
        },
        child: FutureBuilder<List<Announcement>>(
          future: _announcementsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No announcements available.'));
            } else {
              return AnimationLimiter(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final announcement = snapshot.data![index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: AnnouncementCard(announcement: announcement),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementCard({Key? key, required this.announcement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(announcement.title),
        subtitle: Text(announcement.content),
      ),
    );
  }
}

