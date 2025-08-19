import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A simple splash screen that displays a full‑screen logo for a few seconds
/// before routing the user to the appropriate page based on their
/// authentication status.  This screen is shown on app startup.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for three seconds then navigate based on the current user.  The
    // delay gives users a brief intro screen and allows any startup logic
    // (such as Firebase initialisation) to complete.
    Future.delayed(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Display the splash image centered on a dark background.  The
    // splash_logo_new.png file includes the app's logo and tagline.
    return Scaffold(
      // Use a white background so the splash logo image blends seamlessly
      // with its own white background.  This ensures that the logo is
      // centred on a white canvas instead of a dark one.
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splash_logo_center.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}