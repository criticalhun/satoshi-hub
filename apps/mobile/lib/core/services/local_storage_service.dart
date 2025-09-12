import 'dart:convert';

class LocalStorageService {
  // In-memory storage for demo purposes
  final Map<String, String> _storage = {};
  
  // Get value by key
  String? getString(String key) {
    return _storage[key];
  }
  
  // Set value by key
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }
  
  // Get JSON object by key
  Map<String, dynamic>? getJson(String key) {
    final jsonString = _storage[key];
    if (jsonString == null) return null;
    
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
  
  // Set JSON object by key
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    _storage[key] = json.encode(value);
  }
  
  // Get list of JSON objects by key
  List<Map<String, dynamic>>? getJsonList(String key) {
    final jsonString = _storage[key];
    if (jsonString == null) return null;
    
    try {
      final list = json.decode(jsonString) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }
  
  // Set list of JSON objects by key
  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    _storage[key] = json.encode(value);
  }
  
  // Remove value by key
  Future<void> remove(String key) async {
    _storage.remove(key);
  }
  
  // Clear all values
  Future<void> clear() async {
    _storage.clear();
  }
  
  // Check if key exists
  bool containsKey(String key) {
    return _storage.containsKey(key);
  }
  
  // Get all keys
  Set<String> getKeys() {
    return _storage.keys.toSet();
  }
  
  // Get transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    return getJsonList('transactions') ?? [];
  }
  
  // Save transactions
  Future<void> saveTransactions(List<Map<String, dynamic>> transactions) async {
    await setJsonList('transactions', transactions);
  }
  
  // Get tokens
  Future<List<Map<String, dynamic>>> getTokens() async {
    return getJsonList('tokens') ?? [];
  }
  
  // Save tokens
  Future<void> saveTokens(List<Map<String, dynamic>> tokens) async {
    await setJsonList('tokens', tokens);
  }
}
