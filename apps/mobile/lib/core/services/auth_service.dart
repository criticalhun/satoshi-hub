import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:satoshi_hub/core/services/api_client.dart';
import 'package:satoshi_hub/core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String walletAddress;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.walletAddress,
    required this.createdAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      walletAddress: json['walletAddress'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'walletAddress': walletAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  
  ApiClient get _apiClient => ApiClient(authToken: _token);
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  
  // Konstruktor
  AuthService() {
    _loadUserFromStorage();
  }
  
  // Felhasználó betöltése a helyi tárolóból
  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      final storedUserJson = prefs.getString('user');
      
      if (storedToken != null && storedUserJson != null) {
        _token = storedToken;
        Map<String, dynamic> userData = json.decode(storedUserJson);
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'Failed to load user: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Felhasználó mentése a helyi tárolóba
  Future<void> _saveUserToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_token != null && _currentUser != null) {
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user', json.encode(_currentUser!.toJson()));
    }
  }
  
  // Bejelentkezés
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // API-val való kommunikáció helyett mockolt adatokkal dolgozunk
      await Future.delayed(Duration(milliseconds: 1000));
      
      // Mock bejelentkezés
      if (email == 'test@example.com' && password == 'password') {
        _token = 'mock_token_12345';
        _currentUser = User(
          id: '1',
          username: 'testuser',
          email: email,
          walletAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
          createdAt: DateTime.now().subtract(Duration(days: 30)),
        );
        _isAuthenticated = true;
        
        await _saveUserToStorage();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Valós API implementáció később:
      /*
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.success) {
        _token = response.data!['token'];
        _currentUser = User.fromJson(response.data!['user']);
        _isAuthenticated = true;
        
        await _saveUserToStorage();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Regisztráció
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Mock regisztráció
      await Future.delayed(Duration(milliseconds: 1000));
      
      _token = 'mock_token_12345';
      _currentUser = User(
        id: '1',
        username: username,
        email: email,
        walletAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
        createdAt: DateTime.now(),
      );
      _isAuthenticated = true;
      
      await _saveUserToStorage();
      
      _isLoading = false;
      notifyListeners();
      return true;
      
      // Valós API implementáció később:
      /*
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.register,
        body: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      
      if (response.success) {
        _token = response.data!['token'];
        _currentUser = User.fromJson(response.data!['user']);
        _isAuthenticated = true;
        
        await _saveUserToStorage();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Kijelentkezés
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user');
      
      _token = null;
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Kapcsolat a wallet-tel
  Future<bool> connectWallet(String address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Mock wallet kapcsolat
      await Future.delayed(Duration(milliseconds: 500));
      
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          username: _currentUser!.username,
          email: _currentUser!.email,
          walletAddress: address,
          createdAt: _currentUser!.createdAt,
        );
        
        await _saveUserToStorage();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'No user logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Valós API implementáció később:
      /*
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/users/wallet',
        body: {
          'walletAddress': address,
        },
      );
      
      if (response.success) {
        _currentUser = User.fromJson(response.data!['user']);
        
        await _saveUserToStorage();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to connect wallet';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      */
    } catch (e) {
      _error = 'Failed to connect wallet: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
