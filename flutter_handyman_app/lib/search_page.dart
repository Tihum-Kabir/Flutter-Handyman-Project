import 'package:flutter/material.dart';
import 'services/handyman_list.dart';
import 'widgets/bottom_nav.dart';

/// Simple search page allowing users to search for service categories.
/// It displays a list of known categories and filters them based on the
/// search query.  Tapping a category navigates to the corresponding list.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<String> _categories = const [
    'Plumber',
    'Technician',
    'Electrician',
    'Carpenter',
    'Painter',
    'Cleaner',
  ];
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _categories
        .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Search')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search services…',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                fillColor: Colors.black.withOpacity(0.3),
                filled: true,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final category = filtered[index];
                  return Card(
                    color: Colors.black.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(category, style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HandymanListPage(category: category),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          _navigate(context, index);
        },
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 3:
        // already on search
        break;
    }
  }
}