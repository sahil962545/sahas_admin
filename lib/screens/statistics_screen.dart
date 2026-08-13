import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../utils/theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.find<ReportController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final total = controller.totalReportsCount;
        final happy = controller.happyReportsCount;
        final normal = controller.normalReportsCount;
        final sad = controller.sadReportsCount;
        final sick = controller.sickReportsCount;
        final emergency = controller.emergencyReportsCount;
        final today = controller.reportsTodayCount;
        final thisWeek = controller.reportsThisWeekCount;

        if (total == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Data Available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Receive or sync SAHAS reports from SMS to view statistical analytics.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isWide = width >= 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Total Reports Header Card
                  _buildTotalReportsCard(context, total),
                  const SizedBox(height: 16),

                  // 2. Timeline Summaries (Today / This Week)
                  _buildTimelineSummaryRow(context, today: today, thisWeek: thisWeek, isWide: isWide),
                  const SizedBox(height: 24),

                  // 3. Mood Distribution Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Mood Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Grid of Mood Breakdowns
                  _buildMoodGrid(
                    context,
                    isWide: isWide,
                    total: total,
                    happy: happy,
                    normal: normal,
                    sad: sad,
                    sick: sick,
                    emergency: emergency,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTotalReportsCard(BuildContext context, int total) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL REPORTS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$total',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Parsed and locally cached reports',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.summarize_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSummaryRow(
    BuildContext context, {
    required int today,
    required int thisWeek,
    required bool isWide,
  }) {
    final children = [
      Expanded(
        child: _buildCountCard(
          context,
          title: 'Today',
          count: today,
          icon: Icons.today_rounded,
          color: Colors.teal,
        ),
      ),
      SizedBox(width: isWide ? 16 : 12),
      Expanded(
        child: _buildCountCard(
          context,
          title: 'This Week',
          count: thisWeek,
          icon: Icons.date_range_rounded,
          color: Colors.blueAccent,
        ),
      ),
    ];

    return isWide
        ? Row(children: children)
        : Row(children: children);
  }

  Widget _buildCountCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
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

  Widget _buildMoodGrid(
    BuildContext context, {
    required bool isWide,
    required int total,
    required int happy,
    required int normal,
    required int sad,
    required int sick,
    required int emergency,
  }) {
    final List<Map<String, dynamic>> items = [
      {'mood': 'Happy', 'count': happy, 'style': getMoodStyle('Happy')},
      {'mood': 'Normal', 'count': normal, 'style': getMoodStyle('Normal')},
      {'mood': 'Sad', 'count': sad, 'style': getMoodStyle('Sad')},
      {'mood': 'Sick', 'count': sick, 'style': getMoodStyle('Sick')},
      {'mood': 'Emergency', 'count': emergency, 'style': getMoodStyle('Emergency')},
    ];

    final double ratio = isWide ? 2.5 : 1.3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: ratio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final String mood = item['mood'];
        final int count = item['count'];
        final MoodStyle style = item['style'];
        final double percentage = total > 0 ? (count / total) * 100 : 0.0;

        return Card(
          margin: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: style.color,
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      style.icon,
                      color: style.color,
                      size: 24,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  mood,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
