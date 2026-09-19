import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';

class DashboardChartCard extends StatefulWidget {
  final DashboardModel dashboard;
  final bool isLoading;
  final VoidCallback? onTap;
  final void Function(String sentiment)? onSentimentTap;
  final bool isExpanded;

  const DashboardChartCard({
    super.key,
    required this.dashboard,
    this.isLoading = false,
    this.onTap,
    this.onSentimentTap,
    this.isExpanded = false,
  });

  @override
  State<DashboardChartCard> createState() => _DashboardChartCardState();
}

class _DashboardChartCardState extends State<DashboardChartCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.dashboard.total;
    final happy = widget.dashboard.happy;
    final unhappy = widget.dashboard.unhappy;
    final emergency = widget.dashboard.emergency;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          Icons.pie_chart_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Overview Dashboard',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (widget.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Top Metric Summary Cards
              Row(
                children: [
                  _buildStatBadge(
                    context,
                    title: 'Total',
                    count: total,
                    color: const Color(0xFF6366F1),
                    icon: Icons.reviews_rounded,
                    onTap: () {
                      widget.onSentimentTap?.call('');
                      widget.onTap?.call();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    context,
                    title: 'Happy',
                    count: happy,
                    color: const Color(0xFF10B981),
                    icon: Icons.sentiment_satisfied_alt_rounded,
                    onTap: () {
                      widget.onSentimentTap?.call('happy');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    context,
                    title: 'Unhappy',
                    count: unhappy,
                    color: const Color(0xFFF59E0B),
                    icon: Icons.sentiment_dissatisfied_rounded,
                    onTap: () {
                      widget.onSentimentTap?.call('unhappy');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    context,
                    title: 'Emergency',
                    count: emergency,
                    color: const Color(0xFFEF4444),
                    icon: Icons.warning_amber_rounded,
                    onTap: () {
                      widget.onSentimentTap?.call('emergency');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // fl_chart Donut Chart
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            if (event is FlTapUpEvent) {
                              final sections = _showingSections(
                                  total, happy, unhappy, emergency);
                              if (pieTouchResponse != null &&
                                  pieTouchResponse.touchedSection != null) {
                                final idx = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                                if (idx >= 0 && idx < sections.length) {
                                  final sectionColor = sections[idx].color;
                                  if (sectionColor == const Color(0xFF10B981)) {
                                    widget.onSentimentTap?.call('happy');
                                    return;
                                  } else if (sectionColor ==
                                      const Color(0xFFF59E0B)) {
                                    widget.onSentimentTap?.call('unhappy');
                                    return;
                                  } else if (sectionColor ==
                                      const Color(0xFFEF4444)) {
                                    widget.onSentimentTap?.call('emergency');
                                    return;
                                  }
                                }
                              }
                              widget.onTap?.call();
                            }
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 55,
                        sections:
                            _showingSections(total, happy, unhappy, emergency),
                      ),
                    ),
                    // Center Text inside Donut
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Total Reviews',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Legend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(
                    color: const Color(0xFF10B981),
                    text: 'Happy (${_calcPercent(happy, total)}%)',
                  ),
                  const SizedBox(width: 14),
                  _buildLegendItem(
                    color: const Color(0xFFF59E0B),
                    text: 'Unhappy (${_calcPercent(unhappy, total)}%)',
                  ),
                  const SizedBox(width: 14),
                  _buildLegendItem(
                    color: const Color(0xFFEF4444),
                    text: 'Emergency (${_calcPercent(emergency, total)}%)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calcPercent(int count, int total) {
    if (total == 0) return '0';
    final pct = (count / total) * 100;
    return pct.toStringAsFixed(pct.truncateToDouble() == pct ? 0 : 1);
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
    int total,
    int happy,
    int unhappy,
    int emergency,
  ) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.withValues(alpha: 0.2),
          value: 1,
          title: '',
          radius: 20,
        ),
      ];
    }

    final List<PieChartSectionData> sections = [];

    if (happy > 0) {
      final isTouched = touchedIndex == sections.length;
      final radius = isTouched ? 28.0 : 22.0;
      sections.add(
        PieChartSectionData(
          color: const Color(0xFF10B981),
          value: happy.toDouble(),
          title: '$happy',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (unhappy > 0) {
      final isTouched = touchedIndex == sections.length;
      final radius = isTouched ? 28.0 : 22.0;
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFF59E0B),
          value: unhappy.toDouble(),
          title: '$unhappy',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    if (emergency > 0) {
      final isTouched = touchedIndex == sections.length;
      final radius = isTouched ? 28.0 : 22.0;
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFEF4444),
          value: emergency.toDouble(),
          title: '$emergency',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
