import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  AuthStatus _status = AuthStatus.loading;
  User? _currentUser;
  String? _error;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await _repo.getSessionUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _error = null;
    try {
      final user = await _repo.login(email: email, password: password);
      await _repo.saveSession(user.id!);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error inesperado: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String role,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? description,
  }) async {
    _error = null;
    try {
      final user = await _repo.register(
        role: role,
        name: name,
        email: email,
        phone: phone,
        password: password,
        description: description,
      );
      await _repo.saveSession(user.id!);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error inesperado: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
