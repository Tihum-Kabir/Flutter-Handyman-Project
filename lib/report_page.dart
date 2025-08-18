
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Displays a summary report for a completed order and allows the
/// user to download it as a PDF.  The report includes user info,
/// handyman info, service details, cost and any remarks.
class ReportPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const ReportPage({super.key, required this.orderData});

  Future<Map<String, dynamic>?> _fetchHandyman(String id) async {
    if (id.isEmpty) return null;
    final doc = await FirebaseFirestore.instance.collection('handymen').doc(id).get();
    return doc.data();
  }

  Future<Map<String, dynamic>?> _fetchUser(String id) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    return doc.data();
  }

  Future<void> _generatePdf(BuildContext context) async {
    // Fetch user and handyman information
    final userId = orderData['userId'] as String? ?? '';
    final handymanId = orderData['handymanId'] as String? ?? '';
    final userData = await _fetchUser(userId);
    final handymanData = await _fetchHandyman(handymanId);
    // Build the PDF document
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
              pw.Text('Cost: ৳${(orderData['cost'] ?? 0).toStringAsFixed(2)}'),
              pw.Text('Status: ${orderData['status'] ?? ''}'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Order Report')),
      body: FutureBuilder<Map<String, dynamic>?> (
        future: Future.wait([
          _fetchUser(orderData['userId']),
          _fetchHandyman(orderData['handymanId']),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final userData = snapshot.data?['user'] as Map<String, dynamic>?;
          final handymanData = snapshot.data?['handyman'] as Map<String, dynamic>?;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service Report', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  Text('Service: ${orderData['service']}', style: const TextStyle(color: Colors.white70)),
                  Text('Date: ${DateFormat.yMMMMd().add_jm().format(dateTime)}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Text('User Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  Text('Name: ${userData?['name'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                  Text('Email: ${userData?['email'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                  Text('Phone: ${userData?['phone'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                  Text('Address: ${userData?['address'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Text('Handyman Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                    Text('Name: ${handymanData?['name'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                    Text('Email: ${handymanData?['email'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                    Text('Phone: ${handymanData?['phone'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                    Text('Services: ${(handymanData?['services'] as List<dynamic>?)?.join(', ') ?? ''}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Text('Cost: ৳${(orderData['cost'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
                  Text('Status: ${orderData['status']}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Text('Handyman Remarks', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  Text(orderData['remarks'] ?? 'No remarks provided', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _generatePdf(context),
                      child: const Text('Download PDF'),
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