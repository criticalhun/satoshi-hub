import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/routing_service.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';
import 'package:satoshi_hub/core/models/bridge_route.dart';

class RouteDetailsCard extends StatelessWidget {
  final BridgeRoute route;
  
  const RouteDetailsCard({
    Key? key,
    required this.route,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final routingService = Provider.of<RoutingService>(context);
    final analysis = routingService.getRouteAnalysis(route.id);
    
    if (analysis == null) {
      return const SizedBox();
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              'Route Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Route path visualization
            _buildRoutePathVisualization(context, route),
            const SizedBox(height: 24),
            
            // Advanced metrics
            Text(
              'Advanced Metrics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            
            // Slippage
            _buildMetricRow(
              'Expected Slippage',
              '${analysis.slippage.averageSlippagePercent.toStringAsFixed(2)}%',
              'Min: ${analysis.slippage.minSlippagePercent.toStringAsFixed(2)}%, Max: ${analysis.slippage.maxSlippagePercent.toStringAsFixed(2)}%',
              _getSlippageColor(analysis.slippage.averageSlippagePercent),
            ),
            
            // Liquidity impact
            _buildMetricRow(
              'Liquidity Impact',
              '${(analysis.liquidityImpact * 100).toStringAsFixed(2)}%',
              analysis.liquidityImpact < 0.01 
                  ? 'Minimal impact on pool prices'
                  : analysis.liquidityImpact < 0.05
                      ? 'Low impact on pool prices'
                      : 'Moderate impact on pool prices',
              _getLiquidityImpactColor(analysis.liquidityImpact),
            ),
            
            // Gas efficiency
            _buildMetricRow(
              'Gas Efficiency',
              '${(analysis.gasEfficiency * 100).toStringAsFixed(0)}%',
              analysis.gasEfficiency > 0.8
                  ? 'Excellent gas efficiency'
                  : analysis.gasEfficiency > 0.6
                      ? 'Good gas efficiency'
                      : 'Average gas efficiency',
              _getEfficiencyColor(analysis.gasEfficiency),
            ),
            
            // Security
            _buildMetricRow(
              'Security Score',
              '${analysis.securityScore.toStringAsFixed(0)}/100',
              analysis.securityScore > 90
                  ? 'Very secure route'
                  : analysis.securityScore > 80
                      ? 'Secure route'
                      : analysis.securityScore > 70
                          ? 'Adequately secure route'
                          : 'Use caution with this route',
              _getSecurityColor(analysis.securityScore),
            ),
            
            // Warning if present
            if (analysis.warning != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        analysis.warning!,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRoutePathVisualization(BuildContext context, BridgeRoute route) {
    final chainService = Provider.of<ChainService>(context, listen: false);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Path',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        
        // Route visualization
        for (int i = 0; i < route.hops.length; i++)
          _buildHopVisualization(context, route.hops[i], chainService, i == route.hops.length - 1),
      ],
    );
  }
  
  Widget _buildHopVisualization(
    BuildContext context,
    RouteHop hop,
    ChainService chainService,
    bool isLastHop,
  ) {
    final fromChain = chainService.getChainById(hop.fromChainId);
    final toChain = chainService.getChainById(hop.toChainId);
    
    return Column(
      children: [
        Row(
          children: [
            // From chain
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chainService.getChainColor(hop.fromChainId),
              ),
              child: Center(
                child: Text(
                  fromChain?.shortName.substring(0, 1) ?? '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Provider info
            Expanded(
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Connector line
                    Container(
                      height: 2,
                      color: Colors.white24,
                    ),
                    
                    // Provider badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        hop.provider.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // To chain
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: chainService.getChainColor(hop.toChainId),
              ),
              child: Center(
                child: Text(
                  toChain?.shortName.substring(0, 1) ?? '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Details
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${hop.estimatedTimeMinutes} min',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                'Fee: ${hop.feeAmount.toStringAsFixed(4)} ${hop.feeToken}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Connector to next hop if not the last one
        if (!isLastHop)
          Container(
            margin: const EdgeInsets.only(left: 16),
            width: 2,
            height: 20,
            color: Colors.white24,
          ),
      ],
    );
  }
  
  Widget _buildMetricRow(String label, String value, String description, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white54,
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
  
  Color _getSlippageColor(double slippage) {
    if (slippage < 0.3) return Colors.green;
    if (slippage < 0.8) return Colors.green.withOpacity(0.7);
    if (slippage < 1.5) return Colors.orange;
    return Colors.red;
  }
  
  Color _getLiquidityImpactColor(double impact) {
    final percent = impact * 100;
    if (percent < 1) return Colors.green;
    if (percent < 3) return Colors.green.withOpacity(0.7);
    if (percent < 5) return Colors.orange;
    return Colors.red;
  }
  
Color _getEfficiencyColor(double efficiency) {
    if (efficiency > 0.8) return Colors.green;
    if (efficiency > 0.6) return Colors.green.withOpacity(0.7);
    if (efficiency > 0.4) return Colors.orange;
    return Colors.red;
  }
  
  Color _getSecurityColor(double score) {
    if (score > 90) return Colors.green;
    if (score > 80) return Colors.green.withOpacity(0.7);
    if (score > 70) return Colors.orange;
    return Colors.red;
  }
}
