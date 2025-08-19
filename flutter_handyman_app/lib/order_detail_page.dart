import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'report_page.dart';
import 'review_page.dart';
import 'widgets/bottom_nav.dart';

/// Displays detailed information about a single order.  Shows the
/// service, date/time, cost and status along with user and handyman
/// details.  When the order is complete the user can leave a review
/// and download a PDF report.  Otherwise the order is read‑only.
class OrderDetailPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  const OrderDetailPage({super.key, required this.orderId, required this.orderData});

  Future<Map<String, dynamic>?> _fetchHandyman(String id) async {
    final doc = await FirebaseFirestore.instance.collection('handymen').doc(id).get();
    return doc.data();
  }

  Future<Map<String, dynamic>?> _fetchUser(String id) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.tryParse(orderData['dateTime'] ?? '') ?? DateTime.now();
    final service = orderData['service'] ?? '';
    final status = orderData['status'] ?? '';
    // Safely parse the cost to a double.  Firestore may store the cost
    // as a number or a string.  This conversion handles both cases and
    // defaults to 0.0 on failure.
    double cost;
    final rawCost = orderData['cost'];
    if (rawCost is num) {
      cost = rawCost.toDouble();
    } else if (rawCost is String) {
      cost = double.tryParse(rawCost) ?? 0.0;
    } else {
      cost = 0.0;
    }
    final handymanId = orderData['handymanId'] ?? '';
    final userId = orderData['userId'] ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: FutureBuilder<Map<String, dynamic>?> (
        future: Future.wait([
          _fetchUser(userId),
          _fetchHandyman(handymanId),
        ]).then((results) {
          return {
            'user': results[0],
            'handyman': results[1],
          };
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          final userData = snapshot.data?['user'] as Map<String, dynamic>?;
          final handymanData = snapshot.data?['handyman'] as Map<String, dynamic>?;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service: $service', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Date: ${DateFormat.yMMMMd().add_jm().format(dateTime)}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Cost: ৳${cost.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Status: $status', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text('Handyman', style: Theme.of(context).textTheme.titleMedium),
                Text('Name: ${handymanData?['name'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Email: ${handymanData?['email'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Phone: ${handymanData?['phone'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text('Your Details', style: Theme.of(context).textTheme.titleMedium),
                Text('Name: ${userData?['name'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Email: ${userData?['email'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Phone: ${userData?['phone'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                Text('Address: ${userData?['address'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                if (status == 'processing')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Mark the order as complete and record completion time
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({
                            'status': 'complete',
                            'completedAt': FieldValue.serverTimestamp(),
                          });
                          // Build a copy of orderData with updated status and completion time
                          final updatedOrder = Map<String, dynamic>.from(orderData)
                            ..['status'] = 'complete'
                            ..['completedAt'] = DateTime.now().toIso8601String()
                            ..['id'] = orderId;
                          // Navigate to report page
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportPage(orderData: updatedOrder),
                              ),
                            );
                          }
                        },
                        child: const Text('Order Complete'),
                      ),
                    ],
                  ),
                if (status == 'complete')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Show the Write Review button only if the order has not already been reviewed
                      if (!(orderData['reviewed'] ?? false))
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewPage(
                                  handymanId: handymanId,
                                  orderId: orderId,
                                  handymanName: handymanData?['name'] ?? 'Handyman',
                                ),
                              ),
                            );
                          },
                          child: const Text('Write Review'),
                        ),
                      if (!(orderData['reviewed'] ?? false)) const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final orderWithId = Map<String, dynamic>.from(orderData);
                          orderWithId['id'] = orderId;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportPage(orderData: orderWithId),
                            ),
                          );
                        },
                        child: const Text('Download Report'),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) => _navigate(context, index),
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