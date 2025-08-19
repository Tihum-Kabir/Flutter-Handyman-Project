import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_nav.dart';

/// Page for creating an order for a selected handyman.
///
/// Users select one of the handyman's available services, pick a date and
/// time and then submit the order.  Orders are stored in the
/// `orders` collection in Firestore and include references to both the
/// user and the handyman.  After placing an order the user is returned
/// to the orders page.
/// Page for confirming a booking for a selected handyman.  Users pick
/// a service, date and time.  Before writing the order to Firestore
/// the app checks whether the handyman is available at the requested
/// time.  If the slot is free, the order is saved and the user is
/// redirected to the My Orders page.
class OrderPage extends StatefulWidget {
  final String? handymanId;
  final Map<String, dynamic>? handymanData;
  const OrderPage({super.key, this.handymanId, this.handymanData});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _submitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final services = (widget.handymanData?['services'] as List<dynamic>?)?.cast<String>() ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Service', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedService,
                items: services
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                  fillColor: Colors.black.withOpacity(0.3),
                  filled: true,
                ),
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text('Select Date', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_selectedDate == null
                    ? 'Choose Date'
                    : DateFormat.yMMMMd().format(_selectedDate!)),
              ),
              const SizedBox(height: 16),
              Text('Select Time', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_selectedTime == null
                    ? 'Choose Time'
                    : _selectedTime!.format(context)),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const Spacer(),
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: services.isNotEmpty && _selectedService != null && _selectedDate != null && _selectedTime != null
                            ? () => _placeOrder(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Confirm Booking'),
                      ),
                    ),
            ],
          ),
        ),
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
        Navigator.pushReplacementNamed(context, '/orders');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/search');
        break;
    }
  }

  Future<void> _placeOrder(BuildContext context) async {
    try {
      setState(() {
        _submitting = true;
        _errorMessage = null;
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not signed in');
      }
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      // Check if the handyman already has an order at this exact date/time.
      final existing = await FirebaseFirestore.instance
          .collection('orders')
          .where('handymanId', isEqualTo: widget.handymanId ?? '')
          .where('dateTime', isEqualTo: dateTime.toIso8601String())
          .get();
      if (existing.docs.isNotEmpty) {
        setState(() {
          _errorMessage = 'The selected time is unavailable. Please choose a different slot.';
        });
        return;
      }
      // Determine cost.  Prefer the handyman's advertised cost if provided.
      double cost;
      if (widget.handymanData != null && widget.handymanData!['cost'] != null) {
        final dynamic costVal = widget.handymanData!['cost'];
        if (costVal is num) {
          cost = costVal.toDouble();
        } else if (costVal is String) {
          cost = double.tryParse(costVal) ?? _calculateCost(_selectedService!);
        } else {
          cost = _calculateCost(_selectedService!);
        }
      } else {
        cost = _calculateCost(_selectedService!);
      }
      // Add a 10% app service charge to the base cost.
      cost = cost * 1.10;
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'handymanId': widget.handymanId ?? '',
        'service': _selectedService,
        'dateTime': dateTime.toIso8601String(),
        'cost': cost,
        'status': 'pending',
        'reviewed': false, // track whether a review has been submitted for this order
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/orders', (route) => false);
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

  /// A simple pricing algorithm for demonstration purposes.  In a real
  /// application pricing might come from the selected service or be
  /// calculated based on more complex rules stored in the backend.
  double _calculateCost(String service) {
    // Assign a flat rate based on service name length for demo
    return service.length * 5.0;
  }
}