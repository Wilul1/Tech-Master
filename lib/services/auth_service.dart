import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create UserModel from Firebase User
  UserModel? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // Auth state change stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      // Save auth token to shared preferences
      if (user != null) {
        String? token = await user.getIdToken();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token ?? '');
      }
      
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      // Save auth token to shared preferences
      if (user != null) {
        String? token = await user.getIdToken();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token ?? '');
      }
      
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear auth token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      return;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      return;
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    User? user = _auth.currentUser;
    return _userFromFirebaseUser(user);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('auth_token') ?? '';
    return token.isNotEmpty;
  }
}
