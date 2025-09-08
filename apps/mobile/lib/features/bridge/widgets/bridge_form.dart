import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class BridgeForm extends ConsumerStatefulWidget {
  final bool isLoading;
  final Function(int fromChainId, int toChainId, String to, String amount) onSubmit;

  const BridgeForm({
    Key? key,
    required this.isLoading,
    required this.onSubmit,
  }) : super(key: key);

  @override
  ConsumerState<BridgeForm> createState() => _BridgeFormState();
}

class _BridgeFormState extends ConsumerState<BridgeForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  
  int _fromChainId = AppConstants.supportedChains[0]['chainId'] as int;
  int _toChainId = AppConstants.supportedChains[1]['chainId'] as int;

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // From Chain Selection
          _buildChainSelector(
            label: 'From Chain',
            currentChainId: _fromChainId,
            onChanged: (chainId) {
              setState(() {
                _fromChainId = chainId;
                // If both chains are the same, change the destination chain
                if (_fromChainId == _toChainId) {
                  _toChainId = AppConstants.supportedChains
                      .where((chain) => chain['chainId'] != _fromChainId)
                      .first['chainId'] as int;
                }
              });
            },
          ),
          
          // Swap Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      final temp = _fromChainId;
                      _fromChainId = _toChainId;
                      _toChainId = temp;
                    });
                  },
                ),
              ),
            ),
          ),
          
          // To Chain Selection
          _buildChainSelector(
            label: 'To Chain',
            currentChainId: _toChainId,
            onChanged: (chainId) {
              setState(() {
                _toChainId = chainId;
                // If both chains are the same, change the source chain
                if (_fromChainId == _toChainId) {
                  _fromChainId = AppConstants.supportedChains
                      .where((chain) => chain['chainId'] != _toChainId)
                      .first['chainId'] as int;
                }
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Recipient Address
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipient Address',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '0x...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a recipient address';
                    }
                    if (!value.startsWith('0x') || value.length != 42) {
                      return 'Please enter a valid Ethereum address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.textSecondary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Enter the recipient address on the destination chain',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Please enter a valid number';
                          }
                          if (amount <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'ETH',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Transaction fee: ~0.001 ETH',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // Set max amount logic would go here
                        _amountController.text = '0.1';
                      },
                      child: Text(
                        'MAX',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(
                          _fromChainId,
                          _toChainId,
                          _addressController.text,
                          _amountController.text,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Bridge Assets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainSelector({
    required String label,
    required int currentChainId,
    required Function(int) onChanged,
  }) {
    final chain = AppConstants.supportedChains.firstWhere(
      (chain) => chain['chainId'] == currentChainId,
      orElse: () => AppConstants.supportedChains.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: currentChainId,
            dropdownColor: Colors.black,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: AppConstants.supportedChains.map((chain) {
              return DropdownMenuItem<int>(
                value: chain['chainId'] as int,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          chain['symbol'] as String,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      chain['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
