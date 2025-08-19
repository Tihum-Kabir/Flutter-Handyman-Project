import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Google and Apple sign-in have been removed.  Only email/password
// authentication is supported.  If you wish to re-enable these providers,
// add the appropriate packages back into pubspec.yaml and import them here.

/// Sign‑in screen allowing existing users to authenticate with their
/// email address and password.  If authentication is successful the
/// user is redirected to the dashboard.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // On success the authStateChanges stream in main.dart will rebuild the
      // widget tree.  We also perform an explicit navigation here so that
      // users see immediate feedback after signing in.  This call will
      // replace the sign‑in page with the dashboard.
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      // Provide a more user‑friendly error message for common auth errors.
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          message = 'Your e-mail or password is incorrect.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid e-mail address.';
          break;
        default:
          message = e.message ?? 'Authentication error.';
      }
      setState(() {
        _errorMessage = message;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Google and Apple sign‑in methods have been removed.  Only
  // email/password authentication is available.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
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
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  fillColor: Colors.black.withOpacity(0.3),
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  fillColor: Colors.black.withOpacity(0.3),
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 8),
              // Google and Apple sign‑in buttons have been removed.
              const SizedBox(height: 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reset');
                  },
                  child: const Text('Forgot password?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}