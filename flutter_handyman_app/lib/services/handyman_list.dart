import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../handyman_detail.dart';
import '../widgets/bottom_nav.dart';

/// Generic list page for a given category of handymen.
///
/// The page listens to changes in Firestore and displays a list of
/// available service providers filtered by the supplied [category].  When
/// tapped the user is navigated to a detailed profile page for the
/// selected handyman.
class HandymanListPage extends StatelessWidget {
  final String category;
  const HandymanListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Services'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Filter providers by the selected service category.  We assume the
        // `services` field is stored as an array of strings for each handyman.
        stream: FirebaseFirestore.instance
            .collection('handymen')
            .where('services', arrayContains: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No providers available right now'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final dynamic ratingValue = data['rating'];
              final double rating;
              if (ratingValue is num) {
                rating = ratingValue.toDouble();
              } else if (ratingValue is String) {
                rating = double.tryParse(ratingValue) ?? 0.0;
              } else {
                rating = 0.0;
              }
              return Card(
                color: Colors.black.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty
                        ? NetworkImage(data['photoUrl'])
                        : null,
                    backgroundColor: Colors.grey.shade800,
                    child: (data['photoUrl'] == null || data['photoUrl'].toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(data['name'] ?? 'Unnamed', style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['services'] != null ? (data['services'] as List<dynamic>).join(', ') : '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < rating
                                ? Icons.star
                                : (rating >= i - 0.5 ? Icons.star_half : Icons.star_border),
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HandymanDetailPage(handymanId: docs[index].id),
                        ),
                      );
                    },
                    child: const Text('View'),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
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
        Navigator.pushReplacementNamed(context, '/search');
        break;
    }
  }
}