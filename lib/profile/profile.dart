import 'package:flutter/material.dart';
import 'account.dart';  // Import the AccountPage
import 'orders.dart';   // Import the OrdersPage

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)), // Ensure the title is readable
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 0, 0, 0), const Color.fromARGB(255, 0, 0, 0)],
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
              title: Text(
                'My Account',
                style: TextStyle(color: Colors.white), // Change text color to white
              ),
              leading: Icon(Icons.account_circle, color: Colors.white), // Icon color change
              onTap: () {
                // Navigate to My Account page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage()),
                );
              },
            ),
            Divider(color: Colors.white), // Change divider color to white for better visibility
            // My Orders option
            ListTile(
              title: Text(
                'My Orders',
                style: TextStyle(color: Colors.white), // Change text color to white
              ),
              leading: Icon(Icons.shopping_bag, color: Colors.white), // Icon color change
              onTap: () {
                // Navigate to My Orders page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersPage()),
                );
              },
            ),
            Divider(color: Colors.white), // Divider color
            // Log Out option
            ListTile(
              title: Text(
                'Log Out',
                style: TextStyle(color: Colors.white), // Change text color to white
              ),
              leading: Icon(Icons.logout, color: Colors.white), // Icon color change
              onTap: () {
                // Log out logic goes here
                print('Logging Out');
                // You can add log out functionality here, like clearing session data
              },
            ),
          ],
        ),
      ),
    );
  }
}



