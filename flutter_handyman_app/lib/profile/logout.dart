import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account.dart';  // Import the AccountPage
import 'orders.dart';   // Import the OrdersPage

/// A simple profile page that allows the user to view their
/// account, see their orders and sign out of the application.
///
/// This screen replaces the old `ProfilePage`.  It uses
/// `firebase_auth` to sign the user out when the log‑out
/// button is pressed.  After signing out the user is
/// returned to the sign‑in page.
class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // After signing out, navigate back to the sign‑in page.
    Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000000), Color(0xFF000000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // My Account option
            ListTile(
              title: const Text(
                'My Account',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.account_circle, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountPage()),
                );
              },
            ),
            const Divider(color: Colors.white),
            // My Orders option
            ListTile(
              title: const Text(
                'My Orders',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.shopping_bag, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              },
            ),
            const Divider(color: Colors.white),
            // Log Out option
            ListTile(
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.logout, color: Colors.white),
              onTap: () => _handleSignOut(context),
            ),
          ],
        ),
      ),
    );
  }
}