import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav.dart';

/// Displays the current user's profile information.  Users can view
/// their name, email, phone and address, navigate to edit profile, and log out.
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view profile.')),
      );
    }
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        Widget body;
        if (snapshot.connectionState == ConnectionState.waiting) {
          body = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          body = Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data?.data() ?? {};
          body = Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name'] ?? user.displayName ?? ''}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Email: ${data['email'] ?? user.email ?? ''}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Phone: ${data['phone'] ?? ''}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Address: ${data['address'] ?? ''}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_profile');
                  },
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('My Profile')), 
          body: body,
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              _navigateFromProfile(context, index);
            },
          ),
        );
      },
    );
  }

  void _navigateFromProfile(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on profile
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/search');
        break;
    }
  }
}