import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Import the generated Firebase configuration.  This file is created
// when you run `flutterfire configure` and contains your project setup.
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
import 'profile/my_profile_page.dart';
import 'profile/edit_profile_page.dart';
import 'search_page.dart';
import 'widgets/background.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialise Firebase using the generated configuration.  The
    // flutterfire CLI produces a `firebase_options.dart` file when you run
    // `flutterfire configure`.  Importing that file and passing
    // `DefaultFirebaseOptions.currentPlatform` ensures your app points at the
    // correct Firebase project.  See the Firebase setup docs for details【424927875303443†L548-L573】.
    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // Show a loading indicator while Firebase initializes
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return MaterialApp(
          title: 'Handyman App',
          theme: ThemeData(
            primaryColor: Colors.black,
            scaffoldBackgroundColor: Colors.transparent,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
              bodyMedium: TextStyle(color: Colors.white70),
              titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          // Conditionally wrap pages in the background image.  We don't
          // wrap the splash screen because it is a full‑screen image.
          builder: (context, child) {
            if (child is SplashScreen) {
              return child;
            }
            return Background(child: child ?? const SizedBox.shrink());
          },
          // Show a splash screen while the app determines the user's auth
          // state.  The splash screen will handle routing after a short delay.
          home: const SplashScreen(),
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
            '/profile': (context) => const MyProfilePage(),
            '/edit_profile': (context) => const EditProfilePage(),
            '/search': (context) => const SearchPage(),
            '/order_detail': (context) {
              // This route is not used directly with named navigation.
              // OrderDetailPage requires parameters, so it is typically
              // constructed with MaterialPageRoute.  We include a dummy
              // builder here to satisfy the route map.
              return const SizedBox.shrink();
            },
            '/review': (context) {
              // Like order_detail, reviews are opened via MaterialPageRoute.
              return const SizedBox.shrink();
            },
          },
        );
      },
    );
  }
}
