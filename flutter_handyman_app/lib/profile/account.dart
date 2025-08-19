import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Displays the authenticated user's account information.  It shows
/// details such as name, email, phone number and address, and
/// allows editing of the phone number and address fields.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _editing = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });
    setState(() {
      _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view account.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data?.data() ?? {};
          // Fill controllers with existing data when not editing
          if (!_editing) {
            _phoneController.text = data['phone'] ?? '';
            _addressController.text = data['address'] ?? '';
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['name'] ?? user.displayName ?? ''}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text('Email: ${data['email'] ?? user.email ?? ''}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                _editing
                    ? TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      )
                    : Text('Phone: ${data['phone'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                _editing
                    ? TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      )
                    : Text('Address: ${data['address'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_editing) {
                          _saveChanges(user.uid);
                        } else {
                          setState(() {
                            _editing = true;
                          });
                        }
                      },
                      child: Text(_editing ? 'Save' : 'Edit'),
                    ),
                    const SizedBox(width: 8),
                    if (_editing)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _editing = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



