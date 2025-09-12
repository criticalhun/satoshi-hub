import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satoshi_hub/core/services/price_service.dart';
import 'package:satoshi_hub/shared/widgets/token_chart_widget.dart';
import 'package:satoshi_hub/shared/widgets/price_stats_widget.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';

class TokenPriceScreen extends StatelessWidget {
  final String symbol;
  
  const TokenPriceScreen({
    Key? key,
    required this.symbol,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final priceService = Provider.of<PriceService>(context);
    final priceData = priceService.getPriceData(symbol);
    
    if (priceData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('$symbol Price'),
        ),
        body: Center(
          child: Text(
            'Price data not available',
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
        title: Text('$symbol Price'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceHeader(priceData),
            const SizedBox(height: 24),
            TokenChartWidget(
              chartData: priceService.getChartData(symbol),
              isPriceUp: priceData.isPriceUp,
              timeRange: priceService.selectedTimeRange,
              onTimeRangeChanged: (range) {
                priceService.setTimeRange(range);
              },
            ),
            const SizedBox(height: 24),
            PriceStatsWidget(priceData: priceData),
            const SizedBox(height: 24),
            _buildActionsCard(),
            const SizedBox(height: 24),
            _buildMarketInsights(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceHeader(priceData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priceData.isPriceUp 
                    ? Colors.green.withOpacity(0.2) 
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priceData.formattedPriceChange,
                style: TextStyle(
                  color: priceData.isPriceUp ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionsCard() {
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
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  'Bridge',
                  Icons.swap_horiz,
                  () {
                    // Navigate to Bridge screen
                    Navigator.pop(context);
                    // In a real implementation, we would navigate to the bridge screen with the selected token
                  },
                ),
                _buildActionButton(
                  'Swap',
                  Icons.currency_exchange,
                  () {
                    // Navigate to Advanced Routing screen in swap mode
                    Navigator.pop(context);
                    // In a real implementation, we would navigate to the swap screen with the selected token
                  },
                ),
                _buildActionButton(
                  'Send',
                  Icons.send,
                  () {
                    // Navigate to Send screen
                    Navigator.pop(context);
                    // In a real implementation, we would navigate to the send screen with the selected token
                  },
                ),
                _buildActionButton(
                  'Receive',
                  Icons.qr_code,
                  () {
                    // Navigate to Receive screen
                    Navigator.pop(context);
                    // In a real implementation, we would navigate to the receive screen with the selected token
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMarketInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightRow(
                  'Market Sentiment',
                  _getRandomSentiment(),
                  _getRandomSentimentIcon(),
                ),
                const Divider(color: Colors.white24),
                _buildInsightRow(
                  'Price Prediction (24h)',
                  _getRandomPrediction(),
                  Icons.trending_up,
                ),
                const Divider(color: Colors.white24),
                _buildInsightRow(
                  'Volatility',
                  _getRandomVolatility(),
                  Icons.show_chart,
                ),
                const Divider(color: Colors.white24),
                _buildInsightRow(
                  'Trading Volume Trend',
                  _getRandomVolumeTrend(),
                  Icons.bar_chart,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildNewsSection(),
      ],
    );
  }
  
  Widget _buildInsightRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest News',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildNewsItem(
          'Major Exchange Lists $symbol, Price Surges',
          '2 hours ago',
          'Cryptocurrency exchange Binance has added support for $symbol, leading to a price surge of over 5% in the past 24 hours.',
        ),
        _buildNewsItem(
          '$symbol Foundation Announces New Partnership',
          '5 hours ago',
          'The $symbol Foundation has announced a strategic partnership with a leading blockchain infrastructure provider to enhance network scalability.',
        ),
        _buildNewsItem(
          'Analysts Predict Bullish Trend for $symbol',
          '1 day ago',
          'Market analysts are predicting a bullish trend for $symbol in the coming weeks, citing increased institutional adoption and technical indicators.',
        ),
      ],
    );
  }
  
  Widget _buildNewsItem(String title, String time, String summary) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Read more',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRandomSentiment() {
    final sentiments = [
      'Bullish',
      'Slightly Bullish',
      'Neutral',
      'Slightly Bearish',
      'Bearish',
    ];
    return sentiments[DateTime.now().millisecond % sentiments.length];
  }
  
  IconData _getRandomSentimentIcon() {
    final icons = [
      Icons.trending_up,
      Icons.trending_flat,
      Icons.trending_down,
    ];
    return icons[DateTime.now().millisecond % icons.length];
  }
  
  String _getRandomPrediction() {
    final predictions = [
      'Likely to increase',
      'May consolidate',
      'Potential breakout',
      'Minor retracement expected',
      'Sideways movement',
    ];
    return predictions[DateTime.now().millisecond % predictions.length];
  }
  
  String _getRandomVolatility() {
    final volatilities = [
      'Low',
      'Medium',
      'High',
      'Very High',
      'Decreasing',
    ];
    return volatilities[DateTime.now().millisecond % volatilities.length];
  }
  
  String _getRandomVolumeTrend() {
    final trends = [
      'Increasing',
      'Decreasing',
      'Stable',
      'Fluctuating',
      'Significantly higher',
    ];
    return trends[DateTime.now().millisecond % trends.length];
  }
}
