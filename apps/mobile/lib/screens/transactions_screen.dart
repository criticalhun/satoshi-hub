import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/transaction_service.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransactionType _selectedType = TransactionType.bridge;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedType = TransactionType.bridge;
            break;
          case 1:
            _selectedType = TransactionType.send;
            break;
          case 2:
            _selectedType = TransactionType.receive;
            break;
        }
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'Bridge'),
          Tab(text: 'Send'),
          Tab(text: 'Receive'),
        ],
      ),
    );
  }
  
  Widget _buildTransactionList() {
    final transactionService = Provider.of<TransactionService>(context);
    final chainService = Provider.of<ChainService>(context);
    
    final transactions = transactionService.getTransactionsByType(_selectedType);
    
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForType(_selectedType),
              color: Colors.white24,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getTypeName(_selectedType)} transactions yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(context, transaction, chainService);
      },
    );
  }
  
  IconData _getIconForType(TransactionType type) {
    switch (type) {
      case TransactionType.bridge:
        return Icons.swap_horiz;
      case TransactionType.send:
        return Icons.arrow_upward;
      case TransactionType.receive:
        return Icons.arrow_downward;
      case TransactionType.swap:
        return Icons.currency_exchange;
      case TransactionType.stake:
        return Icons.lock;
      case TransactionType.unstake:
        return Icons.lock_open;
    }
  }
  
  String _getTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.bridge:
        return 'bridge';
      case TransactionType.send:
        return 'send';
      case TransactionType.receive:
        return 'receive';
      case TransactionType.swap:
        return 'swap';
      case TransactionType.stake:
        return 'stake';
      case TransactionType.unstake:
        return 'unstake';
    }
  }
  
  Widget _buildTransactionCard(
    BuildContext context, 
    Transaction transaction,
    ChainService chainService,
  ) {
    String chainName = chainService.getChainName(transaction.chainId);
    
    // Special handling for bridge transactions
    String subtitle;
    if (transaction.type == TransactionType.bridge) {
      final fromChainName = _getChainName(transaction.fromChainId ?? transaction.chainId);
      final toChainName = _getChainName(transaction.toChainId ?? int.tryParse(transaction.toChain ?? '') ?? 0);
      final tokenSymbol = transaction.tokenSymbol ?? _getTokenSymbol(transaction.fromChainId ?? transaction.chainId);
      subtitle = '$fromChainName to $toChainName · $tokenSymbol';
    } else {
      subtitle = '$chainName · ${transaction.tokenSymbol ?? 'ETH'}';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(context, transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForType(transaction.type),
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTypeName(transaction.type).toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(transaction.status.toString()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.amount} ${transaction.tokenSymbol ?? 'ETH'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Recipient',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatAddress(transaction.recipient ?? transaction.to),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Hash',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.txHash != null ? _formatAddress(transaction.txHash!) : _formatAddress(transaction.hash),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(transaction.createdAt ?? transaction.timestamp),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (transaction.status == TransactionStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Provider.of<TransactionService>(context, listen: false)
                          .refreshTransactionStatus(transaction.id);
                      },
                      child: Text('Refresh Status'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(
                          color: AppTheme.primaryColor,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    if (status.contains('confirmed')) {
      color = Colors.green;
      label = 'Confirmed';
    } else if (status.contains('pending')) {
      color = Colors.orange;
      label = 'Pending';
    } else {
      color = Colors.red;
      label = 'Failed';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _formatAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  String _getChainName(int chainId) {
    final chainService = Provider.of<ChainService>(context, listen: false);
    return chainService.getChainName(chainId);
  }
  
  String _getTokenSymbol(int chainId) {
    switch (chainId) {
      case 11155111: // Sepolia
        return 'ETH';
      case 421613: // Arbitrum
        return 'ETH';
      case 420: // Optimism
        return 'ETH';
      case 80001: // Mumbai
        return 'MATIC';
      case 97: // BNB
        return 'BNB';
      case 43113: // Avalanche
        return 'AVAX';
      default:
        return 'ETH';
    }
  }
  
  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Type', _getTypeName(transaction.type).toUpperCase()),
              _buildDetailRow('Status', transaction.status.toString().split('.').last),
              _buildDetailRow('Date', _formatDate(transaction.timestamp)),
              _buildDetailRow('Amount', '${transaction.amount} ${transaction.tokenSymbol ?? 'ETH'}'),
              _buildDetailRow('From', transaction.from),
              _buildDetailRow('To', transaction.to),
              if (transaction.fee != null)
                _buildDetailRow('Fee', '${transaction.fee} ${transaction.feeToken ?? 'ETH'}'),
              _buildDetailRow('Hash', transaction.hash),
              if (transaction.error != null)
                _buildDetailRow('Error', transaction.error!),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
