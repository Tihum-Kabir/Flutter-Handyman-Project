import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../report_mini_page.dart';
import '../order_detail_page.dart';
import '../widgets/bottom_nav.dart';

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
            // We intentionally avoid ordering by a separate field here to prevent the need for a composite index.
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('You have no orders yet.'));
          }
          // Organise orders by status: processing at the top, pending in the middle,
          // and complete at the bottom. Within each group we sort by
          // creation time descending or fall back to the scheduled date/time.
          List<QueryDocumentSnapshot<Map<String, dynamic>>> processingDocs = [];
          List<QueryDocumentSnapshot<Map<String, dynamic>>> pendingDocs = [];
          List<QueryDocumentSnapshot<Map<String, dynamic>>> completeDocs = [];
          for (final doc in docs) {
            final status = doc.data()['status'] ?? 'pending';
            if (status == 'processing') {
              processingDocs.add(doc);
            } else if (status == 'pending') {
              pendingDocs.add(doc);
            } else {
              completeDocs.add(doc);
            }
          }
          int compareDocs(QueryDocumentSnapshot<Map<String, dynamic>> a,
              QueryDocumentSnapshot<Map<String, dynamic>> b) {
            final aCreated = a.data()['createdAt'];
            final bCreated = b.data()['createdAt'];
            if (aCreated is Timestamp && bCreated is Timestamp) {
              return bCreated.compareTo(aCreated);
            }
            final String? aDateStr = a.data()['dateTime'];
            final String? bDateStr = b.data()['dateTime'];
            if (aDateStr != null && bDateStr != null) {
              final aDate = DateTime.tryParse(aDateStr);
              final bDate = DateTime.tryParse(bDateStr);
              if (aDate != null && bDate != null) {
                return bDate.compareTo(aDate);
              }
            }
            return 0;
          }
          processingDocs.sort(compareDocs);
          pendingDocs.sort(compareDocs);
          completeDocs.sort(compareDocs);
          docs = [...processingDocs, ...pendingDocs, ...completeDocs];
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              String status = data['status'] ?? 'pending';
              final service = data['service'] ?? '';
              // Safely parse cost value which may be a string or number
              final dynamic costVal = data['cost'];
              double cost;
              if (costVal is num) {
                cost = costVal.toDouble();
              } else if (costVal is String) {
                cost = double.tryParse(costVal) ?? 0.0;
              } else {
                cost = 0.0;
              }
              // Parse the order date/time string
              final dateTime = DateTime.tryParse(data['dateTime'] ?? '') ?? DateTime.now();

              // Automatically transition from pending to processing when the
              // scheduled date/time has passed.  This update is performed on
              // the client when building the list; subsequent rebuilds will
              // reflect the new status from Firestore.  We avoid awaiting
              // the update to prevent blocking the UI.
              if (status == 'pending' && dateTime.isBefore(DateTime.now())) {
                // Update status in Firestore
                FirebaseFirestore.instance
                    .collection('orders')
                    .doc(docs[index].id)
                    .update({'status': 'processing'});
                status = 'processing';
              }
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailPage(
                        orderId: docs[index].id,
                        orderData: data,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.withOpacity(0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'On ${dateTime.toLocal().toString().substring(0, 16)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Status: $status',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '৳${cost.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (status == 'complete')
                            ElevatedButton(
                              onPressed: () {
                                // Build a copy of the order data with the ID for the report
                                final orderWithId = Map<String, dynamic>.from(data);
                                orderWithId['id'] = docs[index].id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MiniReportPage(orderData: orderWithId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Report'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
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
        // already on orders
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/search');
        break;
    }
  }
}



