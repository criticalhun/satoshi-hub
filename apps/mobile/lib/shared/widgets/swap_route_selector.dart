import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/models/swap.dart';
import 'package:satoshi_hub/core/services/swap_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';

class SwapRouteSelector extends StatelessWidget {
  final List<SwapRoute> routes;
  final SwapRoute? selectedRoute;
  final Function(String routeId) onRouteSelected;
  
  const SwapRouteSelector({
    Key? key,
    required this.routes,
    required this.selectedRoute,
    required this.onRouteSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
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
                  Icons.error_outline,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'No Swap Routes Available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No swap routes found for these tokens on this chain.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Routes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildRoutePriorityToggle(context),
        const SizedBox(height: 16),
        ...routes.map((route) => _buildRouteCard(context, route)).toList(),
      ],
    );
  }
  
  Widget _buildRoutePriorityToggle(BuildContext context) {
    final swapService = Provider.of<SwapService>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Priority:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          _buildToggleOption(
            context,
            'Lowest Fees',
            swapService.prioritizeCost,
            () => swapService.setPrioritizeCost(true),
          ),
          const SizedBox(width: 8),
          _buildToggleOption(
            context,
            'Best Rate',
            !swapService.prioritizeCost,
            () => swapService.setPrioritizeCost(false),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToggleOption(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildRouteCard(BuildContext context, SwapRoute route) {
    final isSelected = selectedRoute?.id == route.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected 
          ? AppTheme.primaryColor.withOpacity(0.2) 
          : AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onRouteSelected(route.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: route.isDirectSwap
                              ? Icon(
                                  Icons.swap_horiz,
                                  color: AppTheme.primaryColor,
                                  size: 16,
                                )
                              : Icon(
                                  Icons.compare_arrows,
                                  color: AppTheme.primaryColor,
                                  size: 16,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.routeDescription,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!route.isDirectSwap)
                                Text(
                                  'Via ${_getIntermediateTokens(route)}',
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
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Route Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You Get',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${route.toAmount} ${route.toTokenSymbol}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rate',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1 ${route.fromTokenSymbol} = ${route.effectiveExchangeRate.toStringAsFixed(6)} ${route.toTokenSymbol}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Fees and Impact
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(
                    'Fee',
                    '${route.totalFeeAmount.toStringAsFixed(4)} ${route.primaryFeeToken}',
                    _getFeeColor(route.totalFeeAmount),
                  ),
                  _buildDetailItem(
                    'Price Impact',
                    '${route.totalPriceImpact.toStringAsFixed(2)}%',
                    _getPriceImpactColor(route.totalPriceImpact),
                  ),
                  _buildDetailItem(
                    'Time',
                    _formatTime(route.totalEstimatedTimeSeconds),
                    Colors.white,
                  ),
                ],
              ),
              
              if (route.stepCount > 1) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Text(
                  'Route Steps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...route.steps.map((step) => _buildStepItem(context, step)).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepItem(BuildContext context, SwapQuote step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Text(
              step.fromTokenSymbol.substring(0, 1),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward,
            color: Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Text(
              step.toTokenSymbol.substring(0, 1),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'via ${step.provider.name}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            '${_formatSeconds(step.estimatedTimeSeconds)}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getIntermediateTokens(SwapRoute route) {
    if (route.isDirectSwap) return '';
    
    final tokens = <String>[];
    for (int i = 0; i < route.steps.length - 1; i++) {
      tokens.add(route.steps[i].toTokenSymbol);
    }
    
    return tokens.join(' → ');
  }
  
  Color _getFeeColor(double fee) {
    if (fee < 0.01) return Colors.green;
    if (fee < 0.05) return Colors.green.withOpacity(0.7);
    if (fee < 0.1) return Colors.orange;
    return Colors.red;
  }
  
  Color _getPriceImpactColor(double impact) {
    if (impact < 0.5) return Colors.green;
    if (impact < 1.0) return Colors.green.withOpacity(0.7);
    if (impact < 3.0) return Colors.orange;
    return Colors.red;
  }
  
  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = seconds % 60;
      return '$minutes min ${remainingSeconds > 0 ? '$remainingSeconds sec' : ''}';
    }
  }
  
  String _formatSeconds(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else {
      final minutes = (seconds / 60).floor();
      return '$minutes min';
    }
  }
}
