import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../report_page.dart';

/// Displays the authenticated user's order history.  Orders are
/// streamed from Firestore and include a button to view the final
/// report when the order has been marked as complete.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view orders.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('You have no orders yet.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final status = data['status'] ?? 'pending';
              final service = data['service'] ?? '';
              final cost = data['cost']?.toDouble() ?? 0.0;
              final dateTime = DateTime.tryParse(data['dateTime'] ?? '') ?? DateTime.now();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(service),
                  subtitle: Text('On ${dateTime.toLocal().toString().substring(0, 16)}\nStatus: $status'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('৳${cost.toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      if (status == 'complete')
                        ElevatedButton(
                          onPressed: () {
                            // Include the document ID in the order data so that the
                            // report can display a unique identifier.
                            final orderWithId = Map<String, dynamic>.from(data);
                            orderWithId['id'] = docs[index].id;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportPage(orderData: orderWithId),
                              ),
                            );
                          },
                          child: const Text('Report'),
                        ),
                    ],
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



