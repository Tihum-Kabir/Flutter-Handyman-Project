import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'widgets/bottom_nav.dart';

/// Allows the user to submit a review for a completed order.  Users
/// select a star rating and write a comment.  Upon submission the
/// review is added to the handyman's `reviews` subcollection and
/// the order is marked as reviewed to prevent duplicate feedback.
class ReviewPage extends StatefulWidget {
  final String handymanId;
  final String orderId;
  final String handymanName;
  const ReviewPage({super.key, required this.handymanId, required this.orderId, required this.handymanName});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'You must be signed in to leave a review.';
      });
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please write a comment.';
      });
      return;
    }
    try {
      setState(() {
        _submitting = true;
        _errorMessage = null;
      });
      // Fetch user name for display
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] ?? user.email ?? 'Anonymous';
      // Add review to the handyman's reviews subcollection
      final handymanRef = FirebaseFirestore.instance.collection('handymen').doc(widget.handymanId);
      await handymanRef.collection('reviews').add({
        'userId': user.uid,
        'userName': userName,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Update the handyman's average rating.  We store ratingCount to
      // efficiently compute the new average.  If ratingCount is not set,
      // assume zero.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(handymanRef);
        final data = snapshot.data() ?? {};
        // current rating may be a number or string
        final dynamic currentRatingVal = data['rating'] ?? 0;
        double currentRating;
        if (currentRatingVal is num) {
          currentRating = currentRatingVal.toDouble();
        } else if (currentRatingVal is String) {
          currentRating = double.tryParse(currentRatingVal) ?? 0.0;
        } else {
          currentRating = 0.0;
        }
        final currentCount = (data['ratingCount'] ?? 0) as int;
        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + _rating) / newCount;
        transaction.update(handymanRef, {
          'rating': newRating,
          'ratingCount': newCount,
        });
      });
      // Mark the order as reviewed
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'reviewed': true});
      if (context.mounted) {
        // Show a success message before closing the page.  Use a snackbar
        // so the user knows their review has been submitted.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        // Pop the review page.  Order details page will update from the stream.
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review – ${widget.handymanName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final i = index + 1;
                return IconButton(
                  icon: Icon(
                    i <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = i.toDouble();
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Comment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              // Set the text color to black so the comment is visible on
              // the white background. Without explicitly setting the style
              // the default theme text color (white) makes the text invisible.
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : () => _submitReview(context),
                child: _submitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
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