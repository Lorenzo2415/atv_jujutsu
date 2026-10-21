import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;
  StreamSubscription<User?>? _subscription;
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  void listenToAuthChanges() {
    _subscription?.cancel();
    _subscription = _service.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn() => _service.signInWithGoogle().then((_) {});
  Future<void> signOut() => _service.signOut();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
