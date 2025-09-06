import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _auth.currentUser?.uid;
    } catch (e) {
      print("Sign-in error: $e"); // Enhanced logging
      return null;
    }
  }

  static Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _auth.currentUser?.uid;
    } catch (e) {
      print("Sign-up error: $e"); // Enhanced logging
      return null;
    }
  }

  static Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
