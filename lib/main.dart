import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dashboard.dart';
import 'services/plumber.dart';
import 'services/technician.dart';
import 'services/electrician.dart';
import 'services/carpenter.dart';
import 'services/painter.dart';
import 'services/cleaner.dart';
import 'profile/logout.dart'; // Import the Logout page (renamed from Profile)
import 'profile/account.dart';
import 'profile/orders.dart';
import 'auth/sign_in.dart';
import 'auth/sign_up.dart';
import 'auth/reset_password.dart';
import 'order_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        return MaterialApp(
          title: 'Handyman Services',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            scaffoldBackgroundColor: Colors.black,
          ),
          // Use authStateChanges to decide the initial route.
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              // If the user is signed in, show the dashboard
              if (authSnapshot.connectionState == ConnectionState.active) {
                final user = authSnapshot.data;
                if (user == null) {
                  return const SignInPage();
                } else {
                  return const Dashboard();
                }
              }
              // Otherwise show a loading spinner
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
          routes: {
            '/signin': (context) => const SignInPage(),
            '/signup': (context) => const SignUpPage(),
            '/reset': (context) => const ResetPasswordPage(),
            '/dashboard': (context) => const Dashboard(),
            '/plumber': (context) => const PlumberPage(),
            '/technician': (context) => const TechnicianPage(),
            '/electrician': (context) => const ElectricianPage(),
            '/carpenter': (context) => const CarpenterPage(),
            '/painter': (context) => const PainterPage(),
            '/cleaner': (context) => const CleanerPage(),
            '/logout': (context) => const LogoutPage(),
            '/account': (context) => const AccountPage(),
            '/orders': (context) => const OrdersPage(),
            '/order': (context) => const OrderPage(),
          },
        );
      },
    );
  }
}
