import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';

class UnitSentimentBarChartCard extends StatefulWidget {
  final List<UnitSentimentModel> units;
  final bool isLoading;
  final void Function(String unitId, String sentiment)? onUnitSentimentTap;

  const UnitSentimentBarChartCard({
    super.key,
    required this.units,
    this.isLoading = false,
    this.onUnitSentimentTap,
  });

  static const Color happyColor = Color(0xFF10B981);
  static const Color unhappyColor = Color(0xFFF59E0B);
  static const Color emergencyColor = Color(0xFFEF4444);

  @override
  State<UnitSentimentBarChartCard> createState() =>
      _UnitSentimentBarChartCardState();
}

class _UnitSentimentBarChartCardState extends State<UnitSentimentBarChartCard> {
  int _lastGroupIndex = -1;
  int _lastRodIndex = -1;

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = widget.units;
    final isLoading = widget.isLoading;

    if (units.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    // Determine max Y count for chart scale
    double maxY = 5.0;
    for (final u in units) {
      final maxVal = [u.happy, u.unhappy, u.emergency].reduce(max).toDouble();
      if (maxVal > maxY) {
        maxY = maxVal;
      }
    }
    maxY += 1.0; // Give padding at the top

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit Sentiment Breakdown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap any bar to view filtered review list',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top Legend Indicators
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem(
                  color: UnitSentimentBarChartCard.happyColor,
                  text: 'Happy 😊',
                ),
                _buildLegendItem(
                  color: UnitSentimentBarChartCard.unhappyColor,
                  text: 'Unhappy 🙁',
                ),
                _buildLegendItem(
                  color: UnitSentimentBarChartCard.emergencyColor,
                  text: 'Emergency 🚨',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grouped Bar Chart Area
            isLoading
                ? const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final calculatedWidth = max(
                        constraints.maxWidth,
                        units.length * 75.0,
                      );

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: calculatedWidth,
                          height: 230,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16, top: 12),
                            child: BarChart(
                              BarChartData(
                                maxY: maxY,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchCallback:
                                      (FlTouchEvent event, barTouchResponse) {
                                    if (barTouchResponse != null &&
                                        barTouchResponse.spot != null) {
                                      _lastGroupIndex = barTouchResponse
                                          .spot!.touchedBarGroupIndex;
                                      _lastRodIndex = barTouchResponse
                                          .spot!.touchedRodDataIndex;
                                    }

                                    if (event is FlTapUpEvent ||
                                        event is FlTapDownEvent) {
                                      if (_lastGroupIndex >= 0 &&
                                          _lastGroupIndex < units.length) {
                                        final unit = units[_lastGroupIndex];
                                        String sentiment = '';
                                        if (_lastRodIndex == 0) {
                                          sentiment = 'happy';
                                        } else if (_lastRodIndex == 1) {
                                          sentiment = 'unhappy';
                                        } else if (_lastRodIndex == 2) {
                                          sentiment = 'emergency';
                                        }

                                        if (widget.onUnitSentimentTap != null) {
                                          widget.onUnitSentimentTap!(
                                              unit.id, sentiment);
                                        }
                                        _lastGroupIndex = -1;
                                        _lastRodIndex = -1;
                                      }
                                    }
                                  },
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (group) => theme
                                        .colorScheme.surfaceContainerHighest,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      final unit = units[groupIndex];
                                      String category = 'Happy';
                                      if (rodIndex == 1) category = 'Unhappy';
                                      if (rodIndex == 2) category = 'Emergency';

                                      return BarTooltipItem(
                                        'Unit ${unit.unitName}\n$category: ${rod.toY.toInt()}',
                                        TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      interval: maxY > 10
                                          ? (maxY / 5).roundToDouble()
                                          : 1,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 &&
                                            index < units.length) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              units[index].unitName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: maxY > 10
                                      ? (maxY / 5).roundToDouble()
                                      : 1,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.4),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                    left: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                groupsSpace: 24,
                                barGroups: List.generate(units.length, (index) {
                                  final u = units[index];
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: u.happy.toDouble(),
                                        color: UnitSentimentBarChartCard
                                            .happyColor,
                                        width: 12,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                      BarChartRodData(
                                        toY: u.unhappy.toDouble(),
                                        color: UnitSentimentBarChartCard
                                            .unhappyColor,
                                        width: 12,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                      BarChartRodData(
                                        toY: u.emergency.toDouble(),
                                        color: UnitSentimentBarChartCard
                                            .emergencyColor,
                                        width: 12,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
