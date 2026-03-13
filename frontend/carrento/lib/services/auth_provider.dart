import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  final _api = ApiService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> tryAutoLogin() async {
    final token = await _api.getToken();
    if (token == null) return;
    try {
      final res = await _api.get('/auth/me');
      if (res.data['success']) {
        _user = UserModel.fromJson(res.data['user']);
        notifyListeners();
      }
    } catch (_) {
      await _api.clearToken();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/auth/login', data: {'email': email, 'password': password});
      if (res.data['success']) {
        await _api.saveToken(res.data['token']);
        _user = UserModel.fromJson(res.data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = _parseError(e);
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/auth/register', data: {'name': name, 'email': email, 'password': password, 'phone': phone});
      if (res.data['success']) {
        await _api.saveToken(res.data['token']);
        _user = UserModel.fromJson(res.data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = _parseError(e);
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/auth/profile', data: data);
      if (res.data['success']) {
        _user = UserModel.fromJson(res.data['user']);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('401')) return 'Invalid email or password.';
      if (msg.contains('400')) return 'Email already registered.';
      if (msg.contains('connection')) return 'Cannot connect to server. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
