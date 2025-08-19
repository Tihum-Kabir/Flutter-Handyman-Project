import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Allows a user to request a password reset email.  They need to
/// provide their email address and Firebase will send a reset link
/// to that address.  Feedback is provided to the user once the
/// email has been sent.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _sending = false;
  String? _status;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _status = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _status = 'Password reset email has been sent.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _status = e.message;
      });
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_status != null)
                Text(
                  _status!,
                  style: TextStyle(color: _status!.startsWith('Password') ? Colors.green : Colors.red),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendReset,
                  child: _sending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Reset Email'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}