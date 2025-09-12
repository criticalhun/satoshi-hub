import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/models/token.dart';
import 'package:satoshi_hub/core/services/token_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';

class TokenSelector extends StatelessWidget {
  final int chainId;
  final Function(Token token) onTokenSelected;

  const TokenSelector({
    Key? key,
    required this.chainId,
    required this.onTokenSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tokenService = Provider.of<TokenService>(context);
    final selectedToken = tokenService.selectedToken;
    
    return InkWell(
      onTap: () => _showTokenSelectionDialog(context, tokenService),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.transparent,
              child: Text(
                selectedToken?.symbol.substring(0, 1) ?? 'T',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedToken?.symbol ?? 'Select Token',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Balance: ${selectedToken?.formattedBalance() ?? '0.0'}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showTokenSelectionDialog(BuildContext context, TokenService tokenService) {
    final availableTokens = tokenService.getTokensForChain(chainId);
    
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
                'Select Token',
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
                  itemCount: availableTokens.length,
                  itemBuilder: (context, index) {
                    final token = availableTokens[index];
                    return _buildTokenItem(context, token, tokenService);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenItem(BuildContext context, Token token, TokenService tokenService) {
    final isSelected = tokenService.selectedToken?.address == token.address;
    
    return InkWell(
      onTap: () {
        tokenService.selectToken(token.address);
        onTokenSelected(token);
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
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.transparent,
              child: Text(
                token.symbol.substring(0, 1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    token.symbol,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    token.name,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              token.formattedBalance(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
