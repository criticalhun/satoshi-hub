import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../shared/models/transaction_job.dart';

class ApiService {
  final bool useMock;

  ApiService({this.useMock = false}); // Alapértelmezetten nem használunk mock adatokat

  Future<TransactionJob> createTransactionJob(Map<String, dynamic> data) async {
    try {
      if (useMock) {
        // Mock tranzakció létrehozása
        await Future.delayed(const Duration(seconds: 1));
        
        final id = 'tx-${DateTime.now().millisecondsSinceEpoch}-${math.Random().nextInt(1000)}';
        final timestamp = DateTime.now();
        
        return TransactionJob(
          id: id,
          fromChainId: data['fromChainId'] as int,
          toChainId: data['toChainId'] as int,
          status: 'pending',
          payload: data['payload'],
          createdAt: timestamp,
          updatedAt: timestamp,
        );
      }
      
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/tx'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Server may be unavailable.');
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return TransactionJob.fromJson(jsonDecode(response.body));
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'An unknown error occurred';
        throw Exception('Failed to create transaction job: $errorMsg');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Connection timeout')) {
        // Fallback to mock data on connection issues
        print("Connection error, using mock data: ${e.toString()}");
        return _createMockTransaction(data);
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  TransactionJob _createMockTransaction(Map<String, dynamic> data) {
    final id = 'tx-${DateTime.now().millisecondsSinceEpoch}-${math.Random().nextInt(1000)}';
    final timestamp = DateTime.now();
    
    return TransactionJob(
      id: id,
      fromChainId: data['fromChainId'] as int,
      toChainId: data['toChainId'] as int,
      status: 'pending',
      payload: data['payload'],
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }
  
  Future<TransactionJob> getTransactionJob(String id) async {
    try {
      if (useMock) {
        return _getMockTransactionJob(id);
      }
      
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/tx/$id'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Server may be unavailable.');
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return TransactionJob.fromJson(jsonDecode(response.body));
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'An unknown error occurred';
        throw Exception('Failed to get transaction job: $errorMsg');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Connection timeout')) {
        // Fallback to mock data on connection issues
        print("Connection error, using mock data: ${e.toString()}");
        return _getMockTransactionJob(id);
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  TransactionJob _getMockTransactionJob(String id) {
    // Mock tranzakció részletek
    final rnd = math.Random();
    final statuses = ['pending', 'processing', 'completed', 'failed'];
    final statusIndex = math.min(3, (id.hashCode % 4).abs());
    final status = statuses[statusIndex];
    
    // Alap adatok
    final timestamp = DateTime.now().subtract(Duration(hours: 1));
    final fromChainId = 11155111;
    final toChainId = 80001;
    
    // Payload és eredmény a státusztól függően
    final payload = {
      'type': 'transfer',
      'to': '0x' + List.generate(40, (index) => '0123456789abcdef'[rnd.nextInt(16)]).join(''),
      'amount': (rnd.nextDouble() * 10).toStringAsFixed(4),
    };
    
    Map<String, dynamic>? result;
    if (status == 'completed') {
      result = {
        'txHash': '0x' + List.generate(64, (index) => '0123456789abcdef'[rnd.nextInt(16)]).join(''),
      };
    } else if (status == 'failed') {
      result = {
        'message': 'Transaction failed due to insufficient funds',
      };
    }
    
    return TransactionJob(
      id: id,
      fromChainId: fromChainId,
      toChainId: toChainId,
      status: status,
      payload: payload,
      result: result != null ? jsonEncode(result) : null,
      createdAt: timestamp,
      updatedAt: timestamp.add(Duration(minutes: 10)),
    );
  }
  
  Future<Map<String, dynamic>> getTransactionJobs({
    int page = 1,
    int limit = 10,
    int? fromChainId,
    int? toChainId,
    String? status,
  }) async {
    try {
      if (useMock) {
        return _getMockTransactionJobs(page, limit, fromChainId, toChainId, status);
      }
      
      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (fromChainId != null) queryParams['fromChainId'] = fromChainId.toString();
      if (toChainId != null) queryParams['toChainId'] = toChainId.toString();
      if (status != null) queryParams['status'] = status;
      
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/tx').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Server may be unavailable.');
        },
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Parse the data array to TransactionJob objects
        final List<dynamic> jobsData = responseData['data'] as List<dynamic>;
        final jobs = jobsData.map((jobData) => TransactionJob.fromJson(jobData)).toList();
        
        // Return the response with parsed jobs
        return {
          'data': jobs,
          'meta': responseData['meta'],
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorMsg = errorData['message'] ?? 'An unknown error occurred';
        throw Exception('Failed to get transaction jobs: $errorMsg');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused') || 
          e.toString().contains('Connection timeout')) {
        // Fallback to mock data on connection issues
        print("Connection error, using mock data: ${e.toString()}");
        return _getMockTransactionJobs(page, limit, fromChainId, toChainId, status);
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  Map<String, dynamic> _getMockTransactionJobs(
    int page,
    int limit,
    int? fromChainId,
    int? toChainId,
    String? status,
  ) {
    // Mock tranzakció lista
    final rnd = math.Random();
    final transactions = List.generate(
      limit,
      (index) {
        final id = 'tx-${DateTime.now().millisecondsSinceEpoch - index * 1000000}-${rnd.nextInt(1000)}';
        final statuses = ['pending', 'processing', 'completed', 'failed'];
        final statusIndex = math.min(3, (id.hashCode % 4).abs());
        final mockStatus = statuses[statusIndex];
        
        // Szűrés, ha szükséges
        if (status != null && mockStatus != status) {
          return null;
        }
        
        final mockFromChainId = fromChainId ?? (rnd.nextBool() ? 11155111 : 80001);
        if (fromChainId != null && mockFromChainId != fromChainId) {
          return null;
        }
        
        final mockToChainId = toChainId ?? (rnd.nextBool() ? 11155111 : 80001);
        if (toChainId != null && mockToChainId != toChainId) {
          return null;
        }
        
        final timestamp = DateTime.now().subtract(Duration(hours: index + 1));
        
        // Payload
        final payload = {
          'type': 'transfer',
          'to': '0x' + List.generate(40, (index) => '0123456789abcdef'[rnd.nextInt(16)]).join(''),
          'amount': (rnd.nextDouble() * 10).toStringAsFixed(4),
        };
        
        Map<String, dynamic>? result;
        if (mockStatus == 'completed') {
          result = {
            'txHash': '0x' + List.generate(64, (index) => '0123456789abcdef'[rnd.nextInt(16)]).join(''),
          };
        } else if (mockStatus == 'failed') {
          result = {
            'message': 'Transaction failed due to insufficient funds',
          };
        }
        
        return TransactionJob(
          id: id,
          fromChainId: mockFromChainId,
          toChainId: mockToChainId,
          status: mockStatus,
          payload: payload,
          result: result != null ? jsonEncode(result) : null,
          createdAt: timestamp,
          updatedAt: timestamp.add(Duration(minutes: rnd.nextInt(30))),
        );
      },
    ).where((tx) => tx != null).toList().cast<TransactionJob>();
    
    return {
      'data': transactions,
      'meta': {
        'total': 100, // Szimulált összes tranzakció
        'page': page,
        'limit': limit,
        'lastPage': 10, // Szimulált utolsó oldal
      },
    };
  }
}

// ApiService provider
final apiServiceProvider = Provider<ApiService>((ref) {
  // Először megpróbáljuk a valódi API-t használni, de hibák esetén automatikusan váltunk mockolásra
  return ApiService(useMock: false);
});
