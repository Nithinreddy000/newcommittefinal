import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/member_provider.dart';
import 'providers/visitor_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/poll_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/facility_provider.dart';
import 'providers/visitor_pass_provider.dart';
import 'providers/security_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/resident/resident_dashboard.dart';
import 'screens/security/security_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthService(context),
        ),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => VisitorProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => PollProvider()),
        ChangeNotifierProvider(create: (_) => FacilityProvider()),
        ChangeNotifierProvider(create: (_) => VisitorPassProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: const CommitteeApp(),
    ),
  );
}

class CommitteeApp extends StatelessWidget {
  const CommitteeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Committee Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.currentUser == null) {
          return const LoginScreen();
        }

        switch (auth.currentUser!.role) {
          case 'admin':
            return const AdminDashboard();
          case 'resident':
            return const ResidentDashboard();
          case 'security':
            return const SecurityDashboard();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

