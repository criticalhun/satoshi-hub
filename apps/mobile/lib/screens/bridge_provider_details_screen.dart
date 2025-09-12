import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/bridge_provider_service.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/services/historical_data_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class BridgeProviderDetailsScreen extends StatelessWidget {
  final String providerId;
  
  const BridgeProviderDetailsScreen({
    Key? key,
    required this.providerId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final providerService = Provider.of<BridgeProviderService>(context);
    final chainService = Provider.of<ChainService>(context);
    final historicalDataService = Provider.of<HistoricalDataService>(context);
    
    final provider = providerService.getProviderDetails(providerId);
    
    if (provider == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Provider Details'),
        ),
        body: Center(
          child: Text(
            'Provider not found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProviderHeader(context, provider),
            const SizedBox(height: 24),
            _buildDescription(provider),
            const SizedBox(height: 24),
            _buildSupportedChains(provider, chainService),
            const SizedBox(height: 24),
            _buildSupportedTokens(provider),
            const SizedBox(height: 24),
            _buildFeaturesCard(provider),
            const SizedBox(height: 24),
            _buildPerformanceStats(provider, historicalDataService),
            const SizedBox(height: 24),
            _buildUseCasesCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProviderHeader(BuildContext context, BridgeProviderDetails provider) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            provider.logoUrl,
            width: 48,
            height: 48,
            // If image doesn't exist, show a placeholder
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.white10,
                child: Icon(
                  Icons.shuffle,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reliability Score: ${provider.reliabilityScore.toStringAsFixed(0)}/100',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final url = Uri.parse(provider.website);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
          icon: Icon(Icons.open_in_new, size: 16),
          label: Text('Visit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDescription(BridgeProviderDetails provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          provider.description,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatsRow(provider),
      ],
    );
  }
  
  Widget _buildStatsRow(BridgeProviderDetails provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          'Fee',
          '${provider.feePercentage}%',
          icon: Icons.account_balance_wallet,
        ),
        _buildStatItem(
          'Time',
          '~${provider.typicalTimeMinutes} min',
          icon: Icons.access_time,
        ),
        _buildStatItem(
          'Type',
          provider.features['decentralized'] ? 'Decentralized' : 'Centralized',
          icon: Icons.security,
        ),
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, {required IconData icon}) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSupportedChains(BridgeProviderDetails provider, ChainService chainService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supported Chains',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: provider.supportedChains.map((chainId) {
              final chain = chainService.getChainById(chainId);
              if (chain == null) return SizedBox();
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: chainService.getChainColor(chainId).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: chainService.getChainColor(chainId).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: chainService.getChainColor(chainId),
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
                    Text(
                      chain.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSupportedTokens(BridgeProviderDetails provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supported Tokens',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.supportedTokens.map((token) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                token,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildFeaturesCard(BridgeProviderDetails provider) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureRow('Liquidity Pools', provider.features['hasLiquidityPools']),
            _buildFeatureRow('Message Bridging', provider.features['hasMessageBridging']),
            _buildFeatureRow('Native Token Bridging', provider.features['hasNativeBridging']),
            _buildFeatureRow('Requires Token Approval', provider.features['requiresApproval']),
            _buildFeatureRow('Liquidity Fees', provider.hasLiquidityFees),
            _buildFeatureRow('Gas Fees', provider.hasGasFees),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureRow(String feature, bool isSupported) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isSupported ? Icons.check_circle : Icons.cancel,
            color: isSupported ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceStats(BridgeProviderDetails provider, HistoricalDataService historicalDataService) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceRow(
              'Success Rate',
              '${(provider.reliabilityScore * 0.9).toStringAsFixed(1)}%',
              _getSuccessRateColor(provider.reliabilityScore * 0.9),
            ),
            _buildPerformanceRow(
              'Avg. Execution Time',
              '${provider.typicalTimeMinutes} min',
              _getTimeColor(provider.typicalTimeMinutes),
            ),
            _buildPerformanceRow(
              'Avg. Slippage',
              '${(0.1 + (100 - provider.reliabilityScore) * 0.01).toStringAsFixed(2)}%',
              _getSlippageColor(0.1 + (100 - provider.reliabilityScore) * 0.01),
            ),
            _buildPerformanceRow(
              'Fee Accuracy',
              '${(provider.reliabilityScore * 0.95).toStringAsFixed(1)}%',
              _getFeeAccuracyColor(provider.reliabilityScore * 0.95),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPerformanceRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getSuccessRateColor(double rate) {
    if (rate > 95) return Colors.green;
    if (rate > 90) return Colors.lightGreen;
    if (rate > 80) return Colors.orange;
    return Colors.red;
  }
  
  Color _getTimeColor(int minutes) {
    if (minutes < 5) return Colors.green;
    if (minutes < 10) return Colors.lightGreen;
    if (minutes < 20) return Colors.orange;
    return Colors.red;
  }
  
  Color _getSlippageColor(double slippage) {
    if (slippage < 0.2) return Colors.green;
    if (slippage < 0.5) return Colors.lightGreen;
    if (slippage < 1.0) return Colors.orange;
    return Colors.red;
  }
  
  Color _getFeeAccuracyColor(double accuracy) {
    if (accuracy > 95) return Colors.green;
    if (accuracy > 90) return Colors.lightGreen;
    if (accuracy > 80) return Colors.orange;
    return Colors.red;
  }
  
  Widget _buildUseCasesCard() {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Best Use Cases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildUseCase(
              'Low-Fee Transfers',
              'Ideal for transferring tokens with minimal fees',
              Icons.account_balance_wallet,
            ),
            _buildUseCase(
              'Fast Transactions',
              'Perfect for time-sensitive transfers requiring quick confirmation',
              Icons.speed,
            ),
            _buildUseCase(
              'Security-First Transfers',
              'Best for high-value transfers where security is a priority',
              Icons.security,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUseCase(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
