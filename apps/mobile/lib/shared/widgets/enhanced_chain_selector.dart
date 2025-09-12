import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';

class EnhancedChainSelector extends StatefulWidget {
  final int value;
  final String label;
  final ValueChanged<int?> onChanged;
  final bool showFullList;

  const EnhancedChainSelector({
    Key? key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.showFullList = false,
  }) : super(key: key);

  @override
  _EnhancedChainSelectorState createState() => _EnhancedChainSelectorState();
}

class _EnhancedChainSelectorState extends State<EnhancedChainSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final chainService = Provider.of<ChainService>(context);
    final selectedChain = chainService.getChainById(widget.value);
    final chains = chainService.chains;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          InkWell(
            onTap: () {
              if (widget.showFullList) {
                _showChainSelectionDialog(context, chainService);
              } else {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: chainService.getChainColor(widget.value),
                    ),
                    child: Center(
                      child: Text(
                        selectedChain?.shortName.substring(0, 1) ?? '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedChain?.name ?? 'Select Chain',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && !widget.showFullList)
            _buildQuickChainList(context, chains, chainService),
        ],
      ),
    );
  }

  Widget _buildQuickChainList(BuildContext context, List<dynamic> chains, ChainService chainService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chains.map((chain) {
        final isSelected = chain.chainId == widget.value;
        
        return InkWell(
          onTap: () {
            widget.onChanged(chain.chainId);
            setState(() {
              _isExpanded = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: chainService.getChainColor(chain.chainId),
                  ),
                  child: Center(
                    child: Text(
                      chain.shortName.substring(0, 1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chain.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showChainSelectionDialog(BuildContext context, ChainService chainService) {
    final chains = chainService.chains;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Chain',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: chains.length,
                  itemBuilder: (context, index) {
                    final chain = chains[index];
                    final isSelected = chain.chainId == widget.value;
                    
                    return InkWell(
                      onTap: () {
                        widget.onChanged(chain.chainId);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: chainService.getChainColor(chain.chainId),
                              ),
                              child: Center(
                                child: Text(
                                  chain.shortName.substring(0, 1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chain.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    chain.fullName,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
