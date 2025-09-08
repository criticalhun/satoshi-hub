/// Absztrakt interfész a wallet szolgáltatásokhoz
abstract class WalletServiceInterface {
  /// Csatlakozás a wallet-hez
  Future<bool> connect();
  
  /// Lecsatlakozás a wallet-ről
  Future<void> disconnect();
  
  /// A wallet címének lekérdezése
  Future<String> getAddress();
  
  /// Az egyenleg lekérdezése
  Future<double> getBalance();
  
  /// Tranzakció küldése
  Future<String> sendTransaction({
    required String to,
    required double amount,
    required int chainId,
  });
  
  /// Váltás a megadott láncra
  Future<void> switchChain(int chainId);
  
  /// Erőforrások felszabadítása
  void dispose();
}
