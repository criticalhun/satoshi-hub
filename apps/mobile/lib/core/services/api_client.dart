import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:satoshi_hub/core/config/api_config.dart';

enum RequestMethod { get, post, put, delete }

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;
  final int statusCode;
  
  ApiResponse({
    this.data,
    this.error,
    required this.success,
    required this.statusCode,
  });
  
  factory ApiResponse.success(T? data, int statusCode) {
    return ApiResponse(
      data: data,
      success: true,
      statusCode: statusCode,
    );
  }
  
  factory ApiResponse.error(String error, int statusCode) {
    return ApiResponse(
      error: error,
      success: false,
      statusCode: statusCode,
    );
  }
}

class ApiClient {
  final http.Client _client;
  final String? _authToken;
  
  ApiClient({String? authToken})
    : _client = http.Client(),
      _authToken = authToken;
  
  // GET kérés
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      RequestMethod.get,
      endpoint,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }
  
  // POST kérés
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      RequestMethod.post,
      endpoint,
      body: body,
      fromJson: fromJson,
    );
  }
  
  // PUT kérés
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      RequestMethod.put,
      endpoint,
      body: body,
      fromJson: fromJson,
    );
  }
  
  // DELETE kérés
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _request<T>(
      RequestMethod.delete,
      endpoint,
      body: body,
      fromJson: fromJson,
    );
  }
  
  // Általános kérés handler
  Future<ApiResponse<T>> _request<T>(
    RequestMethod method,
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // URL építése
      var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
      }
      
      // Headers összeállítása
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': ApiConfig.apiKey,
      };
      
      // Auth token hozzáadása, ha van
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // Kérés küldése
      http.Response response;
      switch (method) {
        case RequestMethod.get:
          response = await _client.get(uri, headers: headers)
            .timeout(Duration(milliseconds: ApiConfig.connectTimeout));
          break;
        case RequestMethod.post:
          response = await _client.post(
            uri, 
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));
          break;
        case RequestMethod.put:
          response = await _client.put(
            uri, 
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));
          break;
        case RequestMethod.delete:
          response = await _client.delete(
            uri, 
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));
          break;
      }
      
      // Válasz feldolgozása
      final statusCode = response.statusCode;
      final responseBody = response.body;
      
      if (statusCode >= 200 && statusCode < 300) {
        // Sikeres válasz
        if (responseBody.isEmpty) {
          return ApiResponse<T>.success(null, statusCode);
        }
        
        final jsonData = json.decode(responseBody);
        
        if (fromJson != null) {
          final data = fromJson(jsonData);
          return ApiResponse<T>.success(data, statusCode);
        } else if (T == Map<String, dynamic>) {
          return ApiResponse<T>.success(jsonData as T, statusCode);
        } else if (T == List<dynamic>) {
          return ApiResponse<T>.success(jsonData as T, statusCode);
        } else {
          return ApiResponse<T>.success(jsonData as T, statusCode);
        }
      } else {
        // Hiba válasz
        String errorMessage;
        try {
          final jsonData = json.decode(responseBody);
          errorMessage = jsonData['message'] ?? jsonData['error'] ?? 'Unknown error';
        } catch (_) {
          errorMessage = responseBody.isNotEmpty ? responseBody : 'Unknown error';
        }
        
        return ApiResponse<T>.error(errorMessage, statusCode);
      }
    } on SocketException {
      return ApiResponse<T>.error('No internet connection', 0);
    } on http.ClientException {
      return ApiResponse<T>.error('Connection error', 0);
    } on FormatException {
      return ApiResponse<T>.error('Invalid response format', 0);
    } on TimeoutException {
      return ApiResponse<T>.error('Request timeout', 0);
    } catch (e) {
      return ApiResponse<T>.error('Unexpected error: ${e.toString()}', 0);
    }
  }
  
  // API kliens bezárása
  void close() {
    _client.close();
  }
  
  // Mockolt adatok visszaadása fejlesztési céllal
  Future<ApiResponse<T>> mockResponse<T>({
    required T data,
    int statusCode = 200,
    int delayMs = 500,
  }) async {
    // Késleltetés a valós hálózati kérés szimulálásához
    await Future.delayed(Duration(milliseconds: delayMs));
    
    return ApiResponse<T>.success(data, statusCode);
  }
}
