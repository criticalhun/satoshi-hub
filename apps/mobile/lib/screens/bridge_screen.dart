import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/wallet_service.dart';
import 'package:satoshi_hub/core/services/transaction_service.dart';
import 'package:satoshi_hub/core/services/token_service.dart';
import 'package:satoshi_hub/core/services/fee_service.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/services/routing_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';
import 'package:satoshi_hub/shared/widgets/token_selector.dart';
import 'package:satoshi_hub/shared/widgets/enhanced_chain_selector.dart';
import 'package:satoshi_hub/shared/widgets/route_selector.dart';
import 'package:satoshi_hub/core/models/token.dart';
import 'package:satoshi_hub/core/models/bridge_route.dart';

class BridgeScreen extends StatefulWidget {
  const BridgeScreen({Key? key}) : super(key: key);

  @override
  _BridgeScreenState createState() => _BridgeScreenState();
}

class _BridgeScreenState extends State<BridgeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  int _fromChainId = 11155111; // Sepolia
  int _toChainId = 80001; // Mumbai
  bool _isLoading = false;
  bool _isRoutingLoading = false;
  Token? _selectedToken;
  FeeDetails? _feeDetails;
  List<BridgeRoute> _routes = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set address field to current wallet address
      final walletService = Provider.of<WalletService>(context, listen: false);
      if (walletService.isConnected && walletService.address != null) {
        _addressController.text = walletService.address!;
      }
      
      // Set selected token
      _selectedToken = Provider.of<TokenService>(context, listen: false).selectedToken;
      
      // Add listener to amount field to update routes
      _amountController.addListener(_updateRoutes);
    });
  }
  
  @override
  void dispose() {
    _amountController.removeListener(_updateRoutes);
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  void _updateRoutes() {
    // Only update routes if we have all necessary information
    if (_amountController.text.isNotEmpty && 
        _selectedToken != null && 
        _fromChainId != _toChainId) {
      _findRoutes();
    }
  }
  
  Future<void> _findRoutes() async {
    setState(() {
      _isRoutingLoading = true;
    });
    
    try {
      final routingService = Provider.of<RoutingService>(context, listen: false);
      
      _routes = await routingService.findRoutes(
        fromChainId: _fromChainId,
        toChainId: _toChainId,
        token: _selectedToken!,
        amount: _amountController.text,
      );
      
      // Update fee details from selected route
      if (routingService.selectedRoute != null) {
        final route = routingService.selectedRoute!;
        _feeDetails = FeeDetails(
          gasFee: (route.totalFeeAmount * 0.3).toStringAsFixed(6), // 30% of total fee as gas
          bridgeFee: (route.totalFeeAmount * 0.7).toStringAsFixed(6), // 70% of total fee as bridge fee
          totalFee: route.totalFeeAmount.toStringAsFixed(6),
          feeToken: route.primaryFeeToken,
        );
      } else {
        _feeDetails = null;
      }
    } catch (e) {
      print('Error finding routes: $e');
    } finally {
      setState(() {
        _isRoutingLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    final tokenService = Provider.of<TokenService>(context);
    final feeService = Provider.of<FeeService>(context, listen: false);
    final chainService = Provider.of<ChainService>(context);
    final routingService = Provider.of<RoutingService>(context);
    _selectedToken = tokenService.selectedToken;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bridge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transfer tokens between different blockchains.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          
          // Wallet connection check
          if (!walletService.isConnected)
            _buildWalletWarning()
          else
            _buildBridgeForm(walletService, tokenService, feeService, chainService, routingService),
        ],
      ),
    );
  }
  
  Widget _buildWalletWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Wallet Not Connected',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Please connect your wallet from the home page to use the bridge.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<WalletService>(context, listen: false).connectWallet();
            },
            child: const Text('Connect Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBridgeForm(
    WalletService walletService,
    TokenService tokenService,
    FeeService feeService,
    ChainService chainService,
    RoutingService routingService,
  ) {
    final estimatedTime = feeService.estimateTransactionTime(_fromChainId);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chain selection
        _buildChainSelector(chainService),
        const SizedBox(height: 24),
        
        // Token selection
        const Text(
          'Select Token',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TokenSelector(
          chainId: _fromChainId,
          onTokenSelected: (token) {
            setState(() {
              _selectedToken = token;
              _updateRoutes();
            });
          },
        ),
        const SizedBox(height: 24),
        
        // Amount input
        _buildTextField(
          controller: _amountController,
          label: 'Amount',
          hint: '0.0',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          suffix: Text(
            _selectedToken?.symbol ?? 'TOKEN',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Address input
        _buildTextField(
          controller: _addressController,
          label: 'Recipient Address',
          hint: '0x...',
          suffix: IconButton(
            icon: Icon(
              Icons.content_paste,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            onPressed: () {
              // Paste from clipboard
            },
          ),
        ),
        
        // Balance display
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Balance: ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_selectedToken?.formattedBalance() ?? '0.0'} ${_selectedToken?.symbol ?? ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Route selector
        if (_isRoutingLoading)
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                const SizedBox(height: 12),
                Text(
                  'Finding the best routes...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else if (_amountController.text.isNotEmpty && _routes.isNotEmpty)
          RouteSelector(
            routes: _routes,
            selectedRoute: routingService.selectedRoute,
            onRouteSelected: (routeId) {
              routingService.selectRoute(routeId);
              // Update fee details
              setState(() {
                final route = routingService.selectedRoute!;
                _feeDetails = FeeDetails(
                  gasFee: (route.totalFeeAmount * 0.3).toStringAsFixed(6),
                  bridgeFee: (route.totalFeeAmount * 0.7).toStringAsFixed(6),
                  totalFee: route.totalFeeAmount.toStringAsFixed(6),
                  feeToken: route.primaryFeeToken,
                );
              });
            },
          ),
        
        const SizedBox(height: 24),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading || routingService.selectedRoute == null
                ? null
                : () => _submitBridgeTransaction(context),
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Transfer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
        ),
        
        // Disclaimer
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Note: This is a testnet bridge. Only use testnet tokens.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildChainSelector(ChainService chainService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Chains',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: EnhancedChainSelector(
                value: _fromChainId,
                label: 'From',
                showFullList: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _fromChainId = value;
                      // If both chains are same, switch the destination
                      if (_fromChainId == _toChainId) {
                        // Find a different chain
                        final chains = chainService.chains;
                        for (final chain in chains) {
                          if (chain.chainId != _fromChainId) {
                            _toChainId = chain.chainId;
                            break;
                          }
                        }
                      }
                      _updateRoutes();
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white70,
              ),
            ),
            Expanded(
              child: EnhancedChainSelector(
                value: _toChainId,
                label: 'To',
                showFullList: true,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _toChainId = value;
                      // If both chains are same, switch the source
                      if (_fromChainId == _toChainId) {
                        // Find a different chain
                        final chains = chainService.chains;
                        for (final chain in chains) {
                          if (chain.chainId != _toChainId) {
                            _fromChainId = chain.chainId;
                            break;
                          }
                        }
                      }
                      _updateRoutes();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white24,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white38,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _submitBridgeTransaction(BuildContext context) async {
    // Validation
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    
    if (_addressController.text.isEmpty || !_addressController.text.startsWith('0x')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid address')),
      );
      return;
    }
    
    final walletService = Provider.of<WalletService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    final tokenService = Provider.of<TokenService>(context, listen: false);
    final routingService = Provider.of<RoutingService>(context, listen: false);
    
    // Check if a route is selected
    if (routingService.selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a route')),
      );
      return;
    }
    
    // Check if wallet connected and on correct chain
    if (!walletService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please connect your wallet first')),
      );
      return;
    }
    
    // Check if wallet is on the correct chain
    if (walletService.chainId != _fromChainId) {
      // Ask to switch chain
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardBackgroundColor,
          title: Text('Switch Network', style: TextStyle(color: Colors.white)),
          content: Text(
            'You need to switch to ${Provider.of<ChainService>(context, listen: false).getChainName(_fromChainId)} network to proceed.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await walletService.switchChain(_fromChainId);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to switch network')),
                  );
                }
              },
              child: Text('Switch Network'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
      return;
    }
    
    // Submit transaction
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Simulate token transfer
      final success = await tokenService.simulateTokenTransfer(
        tokenAddress: _selectedToken?.address ?? 'native',
        fromChainId: _fromChainId,
        toChainId: _toChainId,
        amount: _amountController.text,
      );
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient balance')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Get selected route
      final route = routingService.selectedRoute!;
      
      // Submit bridge transaction
      await transactionService.submitBridgeTransaction(
        fromChainId: _fromChainId,
        toChainId: _toChainId,
        amount: _amountController.text,
        recipient: _addressController.text,
        tokenAddress: _selectedToken?.address == 'native' ? null : _selectedToken?.address,
        tokenSymbol: _selectedToken?.symbol,
      );
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaction submitted via ${route.isDirectRoute ? route.hops.first.provider.name : "multi-hop route"}'
          ),
        ),
      );
      
      // Reset form
      _amountController.clear();
      setState(() {
        _routes = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
