import 'package:flutter/material.dart';
import 'widgets/service_card.dart'; // Reusable widget for cards
import 'profile/profile.dart'; // Import the ProfilePage (Make sure the path is correct)

class Dashboard extends StatelessWidget {
  static const List<Map<String, String>> services = [
    {'title': 'Plumber', 'icon': '🛠️', 'route': '/plumber'},
    {'title': 'Technician', 'icon': '🔧', 'route': '/technician'},
    {'title': 'Electrician', 'icon': '💡', 'route': '/electrician'},
    {'title': 'Carpenter', 'icon': '🪚', 'route': '/carpenter'},
    {'title': 'Painter', 'icon': '🎨', 'route': '/painter'},
    {'title': 'Cleaner', 'icon': '🧹', 'route': '/cleaner'},
  ];

  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Change the Home button to just static text
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Home', // Static text indicating the current page
            style: TextStyle(
              color: Colors.white,
              fontSize: 12, // Adjust font size for visibility
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 5),
            TextButton(
              onPressed: () {
                print('Address button pressed');
              },
              child: Text(
                'Add Address',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile_logo.png'),
                backgroundColor: Colors.transparent,
              ),
              onPressed: () {
                print('Profile button pressed');
                // Navigate to the Profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceCard(
                      title: service['title']!,
                      icon: service['icon']!,
                      route: service['route']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
