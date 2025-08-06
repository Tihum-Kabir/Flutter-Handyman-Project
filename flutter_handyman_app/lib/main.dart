//Start of the Flutter Handyman Services app
import 'package:flutter/material.dart';

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
      home: MyHomePage(),
    );
  }
}

//Icons need to be given picture later
class MyHomePage extends StatelessWidget {
  static const List<Map<String, String>> services = [
    {'title': 'Plumber', 'icon': '🛠️'},
    {'title': 'Technician', 'icon': '🔧'},
    {'title': 'Electrician', 'icon': '💡'},
    {'title': 'Carpenter', 'icon': '🪚'},
    {'title': 'Painter', 'icon': '🎨'},
    {'title': 'Cleaner', 'icon': '🧹'},
  ];

  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black], // Full black gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            // Home button functionality is now here
            print('Home button pressed');
          },
          child: Text(
            'Home', // Display "Handyman" on the top left as the app logo
            style: TextStyle(
              color: Colors.white,
              fontSize: 10, // Larger font size for better visibility
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.white), // Address icon
            SizedBox(width: 5),
            TextButton(
              onPressed: () {
                print('Address button pressed');
              },
              child: Text(
                'Add Address', // Change text to "Add address" for better clarity
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Reduced size for address button
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: CircleAvatar(
                backgroundImage: AssetImage(
                  'assets/images/profile_logo.png',
                ), // Profile image from assets
                backgroundColor: Colors
                    .transparent, // Transparent background for profile icon
              ),
              onPressed: () {
                print('Profile button pressed');
                // Add the profile button functionality here
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background_image.png',
            ), // Background image
            fit: BoxFit.cover, // Ensure the image covers the whole background
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar with white background and black text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ), // Black text for placeholder
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ), // Black search icon
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white, // White search bar background
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              // Grid layout for services with smooth hover effect
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Display 2 items per row
                    crossAxisSpacing: 16.0, // Spacing between columns
                    mainAxisSpacing: 16.0, // Spacing between rows
                    childAspectRatio: 1.2, // Aspect ratio for each block
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () {
                        print('Selected ${service['title']}');
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // Set the background color of the tiles to white

                          borderRadius: BorderRadius.circular(
                            15.0,
                          ), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service['icon']!,
                                style: TextStyle(fontSize: 40),
                              ),
                              SizedBox(height: 10),
                              Text(
                                service['title']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Black text color for service titles
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
