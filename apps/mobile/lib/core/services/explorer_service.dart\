import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class ExplorerService {
  /// Visszaadja a megfelelő block explorer URL-t egy tranzakció hash alapján
  String getTransactionExplorerUrl(int chainId, String txHash) {
    final chain = AppConstants.supportedChains.firstWhere(
      (chain) => chain['chainId'] == chainId,
      orElse: () => {'blockExplorer': ''},
    );
    
    final baseUrl = chain['blockExplorer'] as String? ?? '';
    if (baseUrl.isEmpty || txHash.isEmpty) return '';
    
    return '$baseUrl/tx/$txHash';
  }
  
  /// Visszaadja a megfelelő block explorer URL-t egy cím alapján
  String getAddressExplorerUrl(int chainId, String address) {
    final chain = AppConstants.supportedChains.firstWhere(
      (chain) => chain['chainId'] == chainId,
      orElse: () => {'blockExplorer': ''},
    );
    
    final baseUrl = chain['blockExplorer'] as String? ?? '';
    if (baseUrl.isEmpty || address.isEmpty) return '';
    
    return '$baseUrl/address/$address';
  }
  
  /// Megnyit egy URL-t a böngészőben
  Future<bool> launchExplorerUrl(String url) async {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }
  
  /// Megnyit egy tranzakciót a böngészőben
  Future<bool> openTransactionInExplorer(int chainId, String? txHash) async {
    if (txHash == null || txHash.isEmpty) return false;
    
    final url = getTransactionExplorerUrl(chainId, txHash);
    return await launchExplorerUrl(url);
  }
  
  /// Megnyit egy címet a böngészőben
  Future<bool> openAddressInExplorer(int chainId, String address) async {
    final url = getAddressExplorerUrl(chainId, address);
    return await launchExplorerUrl(url);
  }
}

// Provider a szolgáltatáshoz
final explorerServiceProvider = Provider<ExplorerService>((ref) {
  return ExplorerService();
});
