import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Page for creating an order for a selected handyman.
///
/// Users select one of the handyman's available services, pick a date and
/// time and then submit the order.  Orders are stored in the
/// `orders` collection in Firestore and include references to both the
/// user and the handyman.  After placing an order the user is returned
/// to the orders page.
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
      appBar: AppBar(title: const Text('Place Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Service', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedService,
              items: services
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedService = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Date', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
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
              child: Text(_selectedDate == null
                  ? 'Choose Date'
                  : DateFormat.yMMMMd().format(_selectedDate!)),
            ),
            const SizedBox(height: 16),
            Text('Select Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
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
                      child: const Text('Place Order'),
                    ),
                  ),
          ],
        ),
      ),
    );
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
      await FirebaseFirestore.instance.collection('orders').add({
  'userId': user.uid,
  'handymanId': widget.handymanId ?? '',
  'service': _selectedService,
  'dateTime': dateTime.toIso8601String(),
  'cost': _calculateCost(_selectedService!),
  'status': 'pending',
  'createdAt': FieldValue.serverTimestamp(),
});
      // Navigate to orders page after successfully placing the order
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