import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_page.dart';

/// Shows detailed information about a single handyman including
/// services offered, contact information and rating.  From here
/// the user can navigate to the order page to book a service.
class HandymanDetailPage extends StatelessWidget {
  final String handymanId;
  const HandymanDetailPage({super.key, required this.handymanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Handyman Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('handymen')
            .doc(handymanId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found'));
          }
          final data = snapshot.data!.data()!;
          final services = (data['services'] as List<dynamic>?)?.cast<String>() ?? [];
          final rating = (data['rating'] ?? 0).toDouble();
          final availability = data['availability'] ?? true;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty
                          ? NetworkImage(data['photoUrl'])
                          : null,
                      child: (data['photoUrl'] == null || data['photoUrl'].toString().isEmpty)
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['name'] ?? 'Unnamed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text('Services:', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  for (final svc in services)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('- $svc', style: const TextStyle(color: Colors.white70)),
                    ),
                  const SizedBox(height: 16),
                  Text('Contact Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Phone: ${data['phone'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  Text('Email: ${data['email'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  Text('Availability: ${availability ? 'Available' : 'Unavailable'}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderPage(handymanId: handymanId, handymanData: data),
                          ),
                        );
                      },
                      child: const Text('Order Service'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}