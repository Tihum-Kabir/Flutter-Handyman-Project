import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'order_page.dart';
import 'widgets/bottom_nav.dart';

/// Displays a list of available handymen.  Each card shows the
/// handyman's name, rating and services offered along with a
/// "Book Now" button.  Tapping the card opens a detailed pop‑up
/// showing the handyman's full profile, availability and a link to
/// reviews.  The bottom navigation bar provides consistent navigation
/// across the app.
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('handymen').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No handymen available', style: TextStyle(color: Colors.white70)));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final name = data['name'] ?? 'Unnamed';
              // Safely parse rating and cost which may be stored as numbers or strings.
              final dynamic ratingValue = data['rating'];
              final double rating;
              if (ratingValue is num) {
                rating = ratingValue.toDouble();
              } else if (ratingValue is String) {
                rating = double.tryParse(ratingValue) ?? 0.0;
              } else {
                rating = 0.0;
              }
              final services = (data['services'] as List<dynamic>? ?? []).cast<String>();
              final dynamic costValue = data['cost'];
              double cost;
              if (costValue is num) {
                cost = costValue.toDouble();
              } else if (costValue is String) {
                cost = double.tryParse(costValue) ?? 0.0;
              } else {
                cost = 0.0;
              }
              return InkWell(
                onTap: () => _showHandymanDetails(context, doc.id, data),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderPage(
                                    handymanId: doc.id,
                                    handymanData: data,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRatingStars(rating),
                          const SizedBox(width: 8),
                          Text(
                            '৳${cost.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        services.join(', '),
                        style: const TextStyle(color: Colors.white70),
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
        currentIndex: 1,
        onTap: (index) => _navigate(context, index),
      ),
    );
  }

  /// Builds a row of star icons to represent the rating.  Filled
  /// stars correspond to integer parts of the rating and half stars
  /// represent fractional parts.  Empty stars fill the remainder.
  Widget _buildRatingStars(double rating) {
    const totalStars = 5;
    List<Widget> stars = [];
    for (int i = 1; i <= totalStars; i++) {
      if (rating >= i) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (rating >= i - 0.5) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    // When placing this row of stars inside widgets like ListTile.trailing,
    // ensure it does not try to expand to fill all available horizontal space.
    // By setting `mainAxisSize` to `MainAxisSize.min` the row will wrap
    // only around its children, preventing layout overflow errors.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }

  /// Navigates between the bottom navigation destinations.  The order
  /// corresponds to profile, dashboard, orders and search.
  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 1:
        // Already on dashboard
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/search');
        break;
    }
  }

  /// Shows a modal bottom sheet with detailed information about the
  /// selected handyman.  Includes contact details, description,
  /// services, rating and cost as well as buttons to book or view
  /// reviews.
  void _showHandymanDetails(BuildContext context, String handymanId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final name = data['name'] ?? '';
        final email = data['email'] ?? '';
        final phone = data['phone'] ?? '';
        final description = data['description'] ?? '';
        final services = (data['services'] as List<dynamic>? ?? []).cast<String>();
        final rating = (data['rating'] ?? 0).toDouble();
        final cost = (data['cost'] ?? 0).toDouble();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 6,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRatingStars(rating),
                    const SizedBox(width: 8),
                    Text('৳${cost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 12),
                if (description.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(description, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                    ],
                  ),
                const Text('Services', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(services.join(', '), style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Text('Contact', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Email: $email', style: const TextStyle(color: Colors.white70)),
                Text('Phone: $phone', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderPage(
                                handymanId: handymanId,
                                handymanData: data,
                              ),
                            ),
                          );
                        },
                        child: const Text('Book Now'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HandymanReviewsPage(handymanId: handymanId, handymanName: name),
                            ),
                          );
                        },
                        child: const Text('Reviews'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Page that displays reviews for a given handyman.  Reviews are stored
/// in a subcollection `reviews` of each handyman document.  Users can
/// read feedback from past clients.  At the moment this page is
/// read‑only; rating and commenting happens after an order is
/// completed in the order detail page.
class HandymanReviewsPage extends StatelessWidget {
  final String handymanId;
  final String handymanName;
  const HandymanReviewsPage({super.key, required this.handymanId, required this.handymanName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reviews – $handymanName')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('handymen')
            .doc(handymanId)
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data?.docs ?? [];
          // Use a Column with an Expanded ListView to avoid layout issues and
          // semantics assertions related to unbounded height.  This ensures the
          // list occupies the available space above the bottom navigation bar.
          return Column(
            children: [
              if (reviews.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No reviews yet', style: TextStyle(color: Colors.white70)),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 1),
                    itemBuilder: (context, index) {
                      final review = reviews[index].data();
                      // Safely parse rating which may be a number or string
                      final dynamic ratingVal = review['rating'];
                      double rating;
                      if (ratingVal is num) {
                        rating = ratingVal.toDouble();
                      } else if (ratingVal is String) {
                        rating = double.tryParse(ratingVal) ?? 0.0;
                      } else {
                        rating = 0.0;
                      }
                      final comment = review['comment'] ?? '';
                      final userName = review['userName'] ?? 'Anonymous';
                      return ListTile(
                        title: Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(comment, style: const TextStyle(color: Colors.white70)),
                        trailing: _buildRatingStars(rating),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) => _navigate(context, index),
      ),
    );
  }

  /// Reuse the rating stars builder from the Dashboard widget for
  /// consistency.  This method duplicates the logic since there is no
  /// shared state here.
  Widget _buildRatingStars(double rating) {
    const totalStars = 5;
    List<Widget> stars = [];
    for (int i = 1; i <= totalStars; i++) {
      if (rating >= i) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (rating >= i - 0.5) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    // When used as the trailing widget in a ListTile, a Row without
    // specifying `mainAxisSize` will attempt to occupy all remaining
    // horizontal space, which causes layout issues. Limiting the row
    // to the minimal size around its children avoids those errors.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
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