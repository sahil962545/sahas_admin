import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/sahas_report.dart';
import '../screens/report_detail_screen.dart';
import '../utils/theme.dart';

class ReportCard extends StatelessWidget {
  final SahasReport report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final moodStyle = getMoodStyle(report.mood);
    final formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(report.receivedTime);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(() => ReportDetailScreen(report: report));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Employee Name and Mood Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      report.employeeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildMoodBadge(context, report.mood, moodStyle),
                ],
              ),
              const SizedBox(height: 12),
              
              // Remarks section
              Text(
                report.remarks.isNotEmpty ? report.remarks : 'No remarks provided.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              // Divider
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                height: 1,
              ),
              const SizedBox(height: 12),
              
              // Footer Row: Phone Number & Received Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.phoneNumber,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodBadge(BuildContext context, String moodText, MoodStyle moodStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: moodStyle.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: moodStyle.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            moodStyle.icon,
            size: 16,
            color: moodStyle.color,
          ),
          const SizedBox(width: 4),
          Text(
            moodText,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: moodStyle.color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
