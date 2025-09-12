import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/wallet_service.dart';
import 'package:satoshi_hub/core/services/token_service.dart';
import 'package:satoshi_hub/core/services/routing_service.dart';
import 'package:satoshi_hub/core/services/swap_service.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/services/historical_data_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';
import 'package:satoshi_hub/shared/widgets/route_selector.dart';
import 'package:satoshi_hub/shared/widgets/token_selector.dart';
import 'package:satoshi_hub/shared/widgets/enhanced_chain_selector.dart';
import 'package:satoshi_hub/shared/widgets/route_details_card.dart';
import 'package:satoshi_hub/shared/widgets/swap_route_selector.dart';
import 'package:satoshi_hub/core/models/token.dart';

enum RoutingMode {
  bridge,
  swap,
  crossChainSwap,
}

class AdvancedRoutingScreen extends StatefulWidget {
  const AdvancedRoutingScreen({Key? key}) : super(key: key);

  @override
  _AdvancedRoutingScreenState createState() => _AdvancedRoutingScreenState();
}

class _AdvancedRoutingScreenState extends State<AdvancedRoutingScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  RoutingMode _routingMode = RoutingMode.bridge;
  int _fromChainId = 11155111; // Sepolia
  int _toChainId = 80001; // Mumbai
  bool _isLoading = false;
  Token? _fromToken;
  Token? _toToken;
  bool _showAdvancedOptions = false;
  double _slippageTolerance = 0.5; // in percent
  bool _considerSecurity = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set address field to current wallet address
      final walletService = Provider.of<WalletService>(context, listen: false);
      if (walletService.isConnected && walletService.address != null) {
        _addressController.text = walletService.address!;
      }
      
      // Set default tokens
      final tokenService = Provider.of<TokenService>(context, listen: false);
      _fromToken = tokenService.getTokenByAddress('native'); // Native token
      
      if (_routingMode == RoutingMode.swap) {
        // For swap, set default to token
        _toToken = tokenService.getTokenBySymbol('USDT');
      } else if (_routingMode == RoutingMode.crossChainSwap) {
        // For cross-chain swap, set default to tokens
        _fromToken = tokenService.getTokenBySymbol('ETH');
        _toToken = tokenService.getTokenBySymbol('MATIC');
      }
      
      // Add listener to amount field
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
    // Only search routes if we have all necessary data
    if (_amountController.text.isEmpty || _fromToken == null) {
      return;
    }
    
    if (_routingMode == RoutingMode.bridge) {
      _searchBridgeRoutes();
    } else if (_routingMode == RoutingMode.swap) {
      if (_toToken != null) {
        _searchSwapRoutes();
      }
    } else if (_routingMode == RoutingMode.crossChainSwap) {
      if (_toToken != null) {
        _searchCrossChainSwapRoutes();
      }
    }
  }
  
  Future<void> _searchBridgeRoutes() async {
    if (_fromToken == null || _fromChainId == _toChainId) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final routingService = Provider.of<RoutingService>(context, listen: false);
      routingService.setConsiderSecurity(_considerSecurity);
      routingService.setMaxAcceptableSlippage(_slippageTolerance);
      
      await routingService.findRoutes(
        fromChainId: _fromChainId,
        toChainId: _toChainId,
        token: _fromToken!,
        amount: _amountController.text,
      );
    } catch (e) {
      print('Error searching bridge routes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchSwapRoutes() async {
    if (_fromToken == null || _toToken == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final swapService = Provider.of<SwapService>(context, listen: false);
      swapService.setSlippageTolerance(_slippageTolerance);
      
      await swapService.findSwapRoutes(
        fromTokenAddress: _fromToken!.address,
        toTokenAddress: _toToken!.address,
        chainId: _fromChainId,
        amount: _amountController.text,
      );
    } catch (e) {
      print('Error searching swap routes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchCrossChainSwapRoutes() async {
    // For cross-chain swaps, we would combine swap and bridge operations
    // This is just a placeholder for now
    await _searchBridgeRoutes();
  }
  
  @override
  Widget build(BuildContext context) {
    final walletService = Provider.of<WalletService>(context);
    final tokenService = Provider.of<TokenService>(context);
    final routingService = Provider.of<RoutingService>(context);
    final swapService = Provider.of<SwapService>(context);
    final chainService = Provider.of<ChainService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Routing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selector
            _buildModeSelector(),
            const SizedBox(height: 24),
            
            // Wallet connection check
            if (!walletService.isConnected)
              _buildWalletWarning()
            else
              _buildRoutingForm(
                walletService,
                tokenService,
                routingService,
                swapService,
                chainService,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              'Bridge',
              RoutingMode.bridge,
              Icons.swap_horiz,
            ),
          ),
          Expanded(
            child: _buildModeButton(
              'Swap',
              RoutingMode.swap,
              Icons.currency_exchange,
            ),
          ),
          Expanded(
            child: _buildModeButton(
              'Cross-Chain Swap',
              RoutingMode.crossChainSwap,
              Icons.compare_arrows,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeButton(String label, RoutingMode mode, IconData icon) {
    final isSelected = _routingMode == mode;
    
    return InkWell(
      onTap: () {
        setState(() {
          _routingMode = mode;
          _updateRoutes();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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
            'Please connect your wallet from the home page to use advanced routing.',
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
  
  Widget _buildRoutingForm(
    WalletService walletService,
    TokenService tokenService,
    RoutingService routingService,
    SwapService swapService,
    ChainService chainService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chain selection (for bridge and cross-chain swap)
        if (_routingMode != RoutingMode.swap)
          _buildChainSelector(chainService),
        
        // Token selection
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Token',
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
                        _fromToken = token;
                        _updateRoutes();
                      });
                    },
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white70,
              ),
            ),
            
            // To token selection (for swap and cross-chain swap)
            if (_routingMode != RoutingMode.bridge)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To Token',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TokenSelector(
                      chainId: _routingMode == RoutingMode.swap ? _fromChainId : _toChainId,
                      onTokenSelected: (token) {
                        setState(() {
                          _toToken = token;
                          _updateRoutes();
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Amount input
        _buildTextField(
          controller: _amountController,
          label: 'Amount',
          hint: '0.0',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          suffix: Text(
            _fromToken?.symbol ?? 'TOKEN',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Address input (for bridge)
        if (_routingMode == RoutingMode.bridge)
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
                '${_fromToken?.formattedBalance() ?? '0.0'} ${_fromToken?.symbol ?? ''}',
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
        
        // Advanced options toggle
        InkWell(
          onTap: () {
            setState(() {
              _showAdvancedOptions = !_showAdvancedOptions;
            });
          },
          child: Row(
            children: [
              Text(
                'Advanced Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _showAdvancedOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
        
        // Advanced options
        if (_showAdvancedOptions)
          _buildAdvancedOptions(),
        
        const SizedBox(height: 24),
        
        // Route selectors
        if (_isLoading)
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
        else if (_amountController.text.isNotEmpty)
          _buildRouteSelectors(routingService, swapService),
          
        // Route details (if a route is selected)
        if (routingService.selectedRoute != null && _routingMode == RoutingMode.bridge)
          RouteDetailsCard(route: routingService.selectedRoute!),
        
        const SizedBox(height: 24),
        
        // Execute button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canExecute(routingService, swapService) 
                ? () => _executeTransaction(routingService, swapService)
                : null,
            child: Text(_getExecuteButtonText()),
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
  
  Widget _buildAdvancedOptions() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slippage tolerance
          Row(
            children: [
              Text(
                'Slippage Tolerance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_slippageTolerance.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _slippageTolerance,
            min: 0.1,
            max: 5.0,
            divisions: 49,
            activeColor: AppTheme.primaryColor,
            inactiveColor: Colors.white24,
            label: '${_slippageTolerance.toStringAsFixed(1)}%',
            onChanged: (value) {
              setState(() {
                _slippageTolerance = value;
              });
            },
          ),
          
          // Consider security
          Row(
            children: [
              Text(
                'Prioritize Security',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Switch(
                value: _considerSecurity,
                onChanged: (value) {
                  setState(() {
                    _considerSecurity = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          
          Text(
            _considerSecurity
                ? 'Routes will be ranked with security as a factor'
                : 'Routes will be ranked based only on cost and speed',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRouteSelectors(RoutingService routingService, SwapService swapService) {
    if (_routingMode == RoutingMode.bridge) {
      return RouteSelector(
        routes: routingService.availableRoutes,
        selectedRoute: routingService.selectedRoute,
        onRouteSelected: (routeId) {
          routingService.selectRoute(routeId);
        },
      );
    } else if (_routingMode == RoutingMode.swap) {
      return SwapRouteSelector(
        routes: swapService.availableRoutes,
        selectedRoute: swapService.selectedRoute,
        onRouteSelected: (routeId) {
          swapService.selectRoute(routeId);
        },
      );
    } else {
      // For cross-chain swap, we use the bridge routes for now
      return RouteSelector(
        routes: routingService.availableRoutes,
        selectedRoute: routingService.selectedRoute,
        onRouteSelected: (routeId) {
          routingService.selectRoute(routeId);
        },
      );
    }
  }
  
  bool _canExecute(RoutingService routingService, SwapService swapService) {
    if (_amountController.text.isEmpty) return false;
    
    if (_routingMode == RoutingMode.bridge) {
      return routingService.selectedRoute != null &&
             _addressController.text.isNotEmpty &&
             _addressController.text.startsWith('0x');
    } else if (_routingMode == RoutingMode.swap) {
      return swapService.selectedRoute != null;
    } else {
      return routingService.selectedRoute != null;
    }
  }
  
  String _getExecuteButtonText() {
    switch (_routingMode) {
      case RoutingMode.bridge:
        return 'Bridge Tokens';
      case RoutingMode.swap:
        return 'Swap Tokens';
      case RoutingMode.crossChainSwap:
        return 'Cross-Chain Swap';
    }
  }
  
  Future<void> _executeTransaction(RoutingService routingService, SwapService swapService) async {
    // In a real implementation, we would execute the transaction on-chain
    // For this demo, we'll show a success message
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Reset amount
    _amountController.clear();
  }
}
