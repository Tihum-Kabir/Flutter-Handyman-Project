import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'services/plumber.dart'; // Import services
import 'services/technician.dart';
import 'services/electrician.dart';
import 'services/carpenter.dart';
import 'services/painter.dart';
import 'services/cleaner.dart';
import 'profile/profile.dart'; // Import the Profile page
import 'profile/account.dart'; // Import the Account page
import 'profile/orders.dart'; // Import the Orders page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handyman Services',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Dashboard(),
      routes: {
        '/plumber': (context) => PlumberPage(),
        '/technician': (context) => TechnicianPage(),
        '/electrician': (context) => ElectricianPage(),
        '/carpenter': (context) => CarpenterPage(),
        '/painter': (context) => PainterPage(),
        '/cleaner': (context) => CleanerPage(),
        '/profile': (context) => ProfilePage(),
        '/account': (context) => AccountPage(), // Account page route
        '/orders': (context) => OrdersPage(), // Orders page route
      },
    );
  }
}
