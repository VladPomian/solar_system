import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/auth/domain/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAdmin = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = _authService.currentUser;

    if (_user != null) {
      await _checkAdminStatus();
    }

    _isLoading = false;
    notifyListeners();

    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        await _checkAdminStatus();
      } else {
        _isAdmin = false;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _checkAdminStatus() async {
    if (_user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      _isAdmin = doc.data()?['isAdmin'] == true;
    } catch (e) {
      _isAdmin = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}