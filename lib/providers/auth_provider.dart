import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true; // Start in loading state
  String _error = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Initialize by checking if user is already logged in
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    // _isLoading is already true from the start
    try {
      _user = _authService.getCurrentUser(); // Check auth state
    } catch (e) {
      // Handle potential errors during initial check if needed
      _error = 'Failed to initialize user: ${e.toString()}';
      _user = null; // Ensure user is null on error
    } finally {
      _isLoading = false; // Stop loading regardless of success/failure
      notifyListeners(); // Notify UI with the final state (user loaded or not, loading finished)
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.registerWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
