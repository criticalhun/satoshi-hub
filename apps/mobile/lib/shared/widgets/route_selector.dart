import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/models/bridge_route.dart';
import 'package:satoshi_hub/core/services/routing_service.dart';
import 'package:satoshi_hub/core/services/chain_service.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';

class RouteSelector extends StatelessWidget {
  final List<BridgeRoute> routes;
  final BridgeRoute? selectedRoute;
  final Function(String routeId) onRouteSelected;
  
  const RouteSelector({
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
                  'No Routes Available',
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
              'No bridge routes found for this token between the selected chains.',
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
    final routingService = Provider.of<RoutingService>(context);
    
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
            'Cheapest',
            routingService.prioritizeCost,
            () => routingService.setPrioritizeCost(true),
          ),
          const SizedBox(width: 8),
          _buildToggleOption(
            context,
            'Fastest',
            !routingService.prioritizeCost,
            () => routingService.setPrioritizeCost(false),
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
  
  Widget _buildRouteCard(BuildContext context, BridgeRoute route) {
    final chainService = Provider.of<ChainService>(context, listen: false);
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
                          child: route.isDirectRoute
                              ? Icon(
                                  Icons.arrow_forward,
                                  color: AppTheme.primaryColor,
                                  size: 16,
                                )
                              : Icon(
                                  Icons.route,
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
                              if (!route.isDirectRoute)
                                Text(
                                  'Via ${_getIntermediateChainNames(context, route, chainService)}',
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem(
                    context,
                    'Fee',
                    '${route.totalFeeAmount.toStringAsFixed(4)} ${route.primaryFeeToken}',
                    Icons.account_balance_wallet,
                  ),
                  _buildDetailItem(
                    context,
                    'Time',
                    _formatTime(route.totalEstimatedTimeMinutes),
                    Icons.access_time,
                  ),
                  _buildDetailItem(
                    context,
                    'Reliability',
                    '${route.reliabilityScore.toStringAsFixed(0)}%',
                    Icons.verified_user,
                  ),
                ],
              ),
              
              if (route.hopCount > 1) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Text(
                  'Route Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...route.hops.map((hop) => _buildHopItem(context, hop, chainService)).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
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
  
  Widget _buildHopItem(BuildContext context, RouteHop hop, ChainService chainService) {
    final fromChain = chainService.getChainById(hop.fromChainId);
    final toChain = chainService.getChainById(hop.toChainId);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chainService.getChainColor(hop.fromChainId),
            ),
            child: Center(
              child: Text(
                fromChain?.shortName.substring(0, 1) ?? '?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
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
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: chainService.getChainColor(hop.toChainId),
            ),
            child: Center(
              child: Text(
                toChain?.shortName.substring(0, 1) ?? '?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'via ${hop.provider.name}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            '~${hop.estimatedTimeMinutes} min',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getIntermediateChainNames(BuildContext context, BridgeRoute route, ChainService chainService) {
    if (route.isDirectRoute) return '';
    
    final chains = <String>[];
    for (int i = 0; i < route.hops.length - 1; i++) {
      final chainId = route.hops[i].toChainId;
      final chain = chainService.getChainById(chainId);
      if (chain != null) {
        chains.add(chain.name);
      }
    }
    
    return chains.join(', ');
  }
  
  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours h ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}';
    }
  }
}
