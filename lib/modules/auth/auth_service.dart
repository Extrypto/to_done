import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    // Begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // Obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Create new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Finally, sign in and notify listeners
    var userCredential = await _auth.signInWithCredential(credential);
    notifyListeners();
    return userCredential;
  }

  // Check if the user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners(); // Notify listeners after signing out
  }
}
