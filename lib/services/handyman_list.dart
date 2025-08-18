import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../handyman_detail.dart';

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
        stream: FirebaseFirestore.instance
            .collection('handymen')
            .where('category', isEqualTo: category.toLowerCase())
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
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty
                        ? NetworkImage(data['photoUrl'])
                        : null,
                    child: (data['photoUrl'] == null || data['photoUrl'].toString().isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(data['name'] ?? 'Unnamed'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['services'] != null ? (data['services'] as List<dynamic>).join(', ') : ''),
                      Row(
                        children: List.generate(5, (i) {
                          final rating = (data['rating'] ?? 0).toDouble();
                          return Icon(
                            i < rating ? Icons.star : Icons.star_border,
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
    );
  }
}