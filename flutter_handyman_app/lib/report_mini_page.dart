
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// A minimal report view for a completed order.
///
/// This page shows a concise summary of a completed order including
/// the service name, the total cost and the time taken.  It also
/// displays the names of the service provider (handyman) and the
/// recipient (user).  A button is provided to download the full
/// report as a PDF.  The full report contains all order details
/// such as user info, handyman info, start/end times, and remarks.
class MiniReportPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const MiniReportPage({super.key, required this.orderData});

  Future<Map<String, dynamic>?> _fetchHandyman(String id) async {
    if (id.isEmpty) return null;
    final doc = await FirebaseFirestore.instance.collection('handymen').doc(id).get();
    return doc.data();
  }

  Future<Map<String, dynamic>?> _fetchUser(String id) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    return doc.data();
  }

  /// Generates and downloads the full PDF report.  This method
  /// aggregates user and handyman data and formats the report
  /// similarly to the full ReportPage.  It can be called from
  /// anywhere in the widget tree.
  Future<void> _downloadFullReport(BuildContext context) async {
    final userId = orderData['userId'] as String? ?? '';
    final handymanId = orderData['handymanId'] as String? ?? '';
    final userData = await _fetchUser(userId);
    final handymanData = await _fetchHandyman(handymanId);
    final startTime = DateTime.tryParse(orderData['dateTime'] ?? '') ?? DateTime.now();
    // Determine end time using completedAt or now if missing
    DateTime endTime;
    final completedVal = orderData['completedAt'];
    if (completedVal is Timestamp) {
      endTime = completedVal.toDate();
    } else if (completedVal is String) {
      endTime = DateTime.tryParse(completedVal) ?? DateTime.now();
    } else {
      endTime = DateTime.now();
    }
    final duration = endTime.difference(startTime);
    final int totalHours = duration.inHours;
    final int totalMinutes = duration.inMinutes.remainder(60);
    final String timeTaken = '${totalHours}h ${totalMinutes}m';
    // Safely parse cost for PDF
    final dynamic costVal = orderData['cost'] ?? 0;
    double cost;
    if (costVal is num) {
      cost = costVal.toDouble();
    } else if (costVal is String) {
      cost = double.tryParse(costVal) ?? 0.0;
    } else {
      cost = 0.0;
    }
    final pdfDoc = pw.Document();
    pdfDoc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Service Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Order ID: ${orderData['id'] ?? ''}'),
              pw.Text('Service: ${orderData['service'] ?? ''}'),
              pw.Text('Date: ${orderData['dateTime'] ?? ''}'),
              pw.SizedBox(height: 16),
              pw.Text('User Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: ${userData?['name'] ?? ''}'),
              pw.Text('Email: ${userData?['email'] ?? ''}'),
              pw.Text('Phone: ${userData?['phone'] ?? ''}'),
              pw.Text('Address: ${userData?['address'] ?? ''}'),
              pw.SizedBox(height: 16),
              pw.Text('Handyman Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: ${handymanData?['name'] ?? ''}'),
              pw.Text('Email: ${handymanData?['email'] ?? ''}'),
              pw.Text('Phone: ${handymanData?['phone'] ?? ''}'),
              pw.Text('Services: ${(handymanData?['services'] as List<dynamic>?)?.join(', ') ?? ''}'),
              pw.SizedBox(height: 16),
              pw.Text('Cost: ৳${cost.toStringAsFixed(2)}'),
              pw.Text('Status: ${orderData['status'] ?? ''}'),
              pw.Text('Time Taken: $timeTaken'),
              pw.SizedBox(height: 16),
              pw.Text('Handyman Remarks:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(orderData['remarks'] ?? 'No remarks provided'),
            ],
          );
        },
      ),
    );
    final bytes = await pdfDoc.save();
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.tryParse(orderData['dateTime'] ?? '') ?? DateTime.now();
    // Determine end time for calculating duration
    DateTime endTime;
    final completedVal = orderData['completedAt'];
    if (completedVal is Timestamp) {
      endTime = completedVal.toDate();
    } else if (completedVal is String) {
      endTime = DateTime.tryParse(completedVal) ?? DateTime.now();
    } else {
      endTime = DateTime.now();
    }
    final duration = endTime.difference(dateTime);
    final int totalHours = duration.inHours;
    final int totalMinutes = duration.inMinutes.remainder(60);
    final String timeTaken = '${totalHours}h ${totalMinutes}m';
    // Parse cost safely
    final dynamic costVal = orderData['cost'] ?? 0;
    double cost;
    if (costVal is num) {
      cost = costVal.toDouble();
    } else if (costVal is String) {
      cost = double.tryParse(costVal) ?? 0.0;
    } else {
      cost = 0.0;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
      body: FutureBuilder<Map<String, dynamic>?> (
        future: Future.wait([
          _fetchUser(orderData['userId'] ?? ''),
          _fetchHandyman(orderData['handymanId'] ?? ''),
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
          final userName = userData?['name'] ?? '';
          final handymanName = handymanData?['name'] ?? '';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Summary',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text('Service: ${orderData['service']}', style: const TextStyle(color: Colors.white70)),
                Text('Date: ${DateFormat.yMMMMd().add_jm().format(dateTime)}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Text('Provided by: $handymanName', style: const TextStyle(color: Colors.white70)),
                Text('Provided to: $userName', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Text('Cost: ৳${cost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                Text('Time Taken: $timeTaken', style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _downloadFullReport(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Download Full Report'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}