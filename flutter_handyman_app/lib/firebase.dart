// lib/firebase.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';  // Automatically generated Firebase options file

// Initialize Firebase
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Automatically generated Firebase options file
  );
}

// Sign Up Function
Future<User?> signUp(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (e) {
    print("Error signing up: $e");
    return null;
  }
}

// Sign In Function
Future<User?> signIn(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (e) {
    print("Error signing in: $e");
    return null;
  }
}

// Add Worker to Firestore
Future<void> addWorker(String name, String category, double rating) async {
  try {
    // Reference to Firestore collection
    CollectionReference workers = FirebaseFirestore.instance.collection('workers');

    // Add worker data to the collection
    await workers.add({
      'name': name,
      'category': category,
      'rating': rating,
      'reviews': [],  // You can modify this later to allow adding reviews
    }).then((value) {
      print('Worker Added');
    }).catchError((error) {
      print('Failed to add worker: $error');
    });
  } catch (e) {
    print('Error adding worker: $e');
  }
}
