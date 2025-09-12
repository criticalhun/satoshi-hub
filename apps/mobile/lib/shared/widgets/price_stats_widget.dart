import 'package:flutter/material.dart';
import 'package:satoshi_hub/core/models/price_data.dart';

class PriceStatsWidget extends StatelessWidget {
  final PriceData priceData;
  
  const PriceStatsWidget({
    Key? key,
    required this.priceData,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Price', priceData.formattedPrice),
          _buildStatRow('24h Change', priceData.formattedPriceChange, 
            valueColor: priceData.isPriceUp ? Colors.green : Colors.red),
          _buildStatRow('24h High', '\$${priceData.high24h.toStringAsFixed(2)}'),
          _buildStatRow('24h Low', '\$${priceData.low24h.toStringAsFixed(2)}'),
          _buildStatRow('24h Volume', priceData.formattedVolume),
          _buildStatRow('Market Cap', priceData.formattedMarketCap),
          _buildStatRow(
            'Last Updated', 
            '${priceData.lastUpdated.hour.toString().padLeft(2, '0')}:${priceData.lastUpdated.minute.toString().padLeft(2, '0')}'
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
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
              color: valueColor ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
