import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:satoshi_hub/core/models/price_data.dart';
import 'package:satoshi_hub/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TokenChartWidget extends StatefulWidget {
  final List<ChartDataPoint> chartData;
  final bool isPriceUp;
  final String timeRange;
  final Function(String) onTimeRangeChanged;
  
  const TokenChartWidget({
    Key? key,
    required this.chartData,
    required this.isPriceUp,
    required this.timeRange,
    required this.onTimeRangeChanged,
  }) : super(key: key);
  
  @override
  _TokenChartWidgetState createState() => _TokenChartWidgetState();
}

class _TokenChartWidgetState extends State<TokenChartWidget> {
  int touchedIndex = -1;
  
  @override
  Widget build(BuildContext context) {
    if (widget.chartData.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'No chart data available',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    // Calculate min and max values for the chart
    double minY = double.infinity;
    double maxY = 0;
    for (var point in widget.chartData) {
      minY = point.price < minY ? point.price : minY;
      maxY = point.price > maxY ? point.price : maxY;
    }
    
    // Add padding to min and max
    final padding = (maxY - minY) * 0.1;
    minY = minY - padding;
    maxY = maxY + padding;
    
    // Ensure min is not negative
    minY = minY < 0 ? 0 : minY;
    
    return Column(
      children: [
        _buildTimeRangeSelector(),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, widget.chartData),
                    interval: _getInterval(),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _leftTitleWidgets(value, meta, minY, maxY),
                    reservedSize: 40,
                    interval: (maxY - minY) / 4,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: widget.chartData.length.toDouble() - 1,
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black.withOpacity(0.8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final index = spot.x.toInt();
                      if (index >= 0 && index < widget.chartData.length) {
                        final point = widget.chartData[index];
                        return LineTooltipItem(
                          '${DateFormat('MMM d, y HH:mm').format(point.timestamp)}\n',
                          TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${_formatPrice(point.price)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return null;
                      }
                    }).toList();
                  },
                ),
                touchCallback: (event, touchResponse) {
                  setState(() {
                    if (touchResponse?.touchedSpot != null) {
                      touchedIndex = touchResponse!.touchedSpot!.spotIndex;
                    } else {
                      touchedIndex = -1;
                    }
                  });
                },
                handleBuiltInTouches: true,
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(widget.chartData.length, (index) {
                    return FlSpot(index.toDouble(), widget.chartData[index].price);
                  }),
                  isCurved: true,
                  color: widget.isPriceUp ? Colors.green : Colors.red,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: touchedIndex != -1,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: widget.isPriceUp ? Colors.green : Colors.red,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: widget.isPriceUp 
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: widget.isPriceUp
                          ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.05)]
                          : [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.05)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeRangeSelector() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRangeButton('24h', '24h'),
          _buildTimeRangeButton('7d', '7d'),
          _buildTimeRangeButton('30d', '30d'),
        ],
      ),
    );
  }
  
  Widget _buildTimeRangeButton(String label, String value) {
    final isSelected = widget.timeRange == value;
    
    return InkWell(
      onTap: () => widget.onTimeRangeChanged(value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _bottomTitleWidgets(
    double value, 
    TitleMeta meta,
    List<ChartDataPoint> data
  ) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) return Container();
    
    final point = data[index];
    String text;
    
    if (widget.timeRange == '24h') {
      // For 24h chart, show hours
      text = DateFormat('HH:mm').format(point.timestamp);
    } else if (widget.timeRange == '7d') {
      // For 7d chart, show day of week
      text = DateFormat('E').format(point.timestamp);
    } else {
      // For 30d chart, show day of month
      text = DateFormat('d').format(point.timestamp);
    }
    
    // Only show some labels to avoid overcrowding
    if (widget.timeRange == '24h') {
      // Show every 4 hours
      if (point.timestamp.hour % 4 != 0) return Container();
    } else if (widget.timeRange == '7d') {
      // Show every day at noon
      if (point.timestamp.hour != 12) return Container();
    } else {
      // Show every 5 days at noon
      if (point.timestamp.day % 5 != 0 || point.timestamp.hour != 12) return Container();
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 10,
        ),
      ),
    );
  }
  
  Widget _leftTitleWidgets(
    double value,
    TitleMeta meta,
    double minY,
    double maxY
  ) {
    String text;
    
    // Format price based on its value
    text = _formatPrice(value);
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 10,
        ),
      ),
    );
  }
  
  double _getInterval() {
    if (widget.timeRange == '24h') {
      return 4; // Every 4 hours
    } else if (widget.timeRange == '7d') {
      return 24; // Every day
    } else {
      return 120; // Every 5 days
    }
  }
  
  String _formatPrice(double price) {
    if (price < 0.01) {
      return '\$${price.toStringAsFixed(6)}';
    } else if (price < 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else if (price < 10000) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '\$${price.toStringAsFixed(0)}';
    }
  }
}
