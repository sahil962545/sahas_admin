import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/sahas_report.dart';
import '../utils/theme.dart';

class ReportDetailScreen extends StatelessWidget {
  final SahasReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final moodStyle = getMoodStyle(report.mood);
    final formattedTime = DateFormat(
      'EEEE, d MMMM yyyy, hh:mm:ss a',
    ).format(report.receivedTime);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Mood Badge Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    moodStyle.color.withOpacity(0.15),
                    moodStyle.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: moodStyle.color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(moodStyle.icon, size: 64, color: moodStyle.color),
                  const SizedBox(height: 12),
                  Text(
                    report.mood.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: moodStyle.color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Employee Details Section
            _buildSectionHeader(context, 'Employee Information'),
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      icon: Icons.person_outline_rounded,
                      label: 'Employee Name',
                      value: report.employeeName,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: report.phoneNumber,
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () => _copyToClipboard(
                          report.phoneNumber,
                          'Phone number copied',
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      icon: Icons.access_time_rounded,
                      label: 'Received Time',
                      value: formattedTime,
                    ),
                  ],
                ),
              ),
            ),

            // Remarks Section
            _buildSectionHeader(context, 'Remarks'),
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  report.remarks.isNotEmpty
                      ? report.remarks
                      : 'No remarks provided.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),

            // Raw SMS Message Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(context, 'Original SMS Payload'),
                TextButton.icon(
                  onPressed: () => _copyToClipboard(
                    report.originalSms,
                    'SMS payload copied',
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy Raw'),
                ),
              ],
            ),
            Card(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              margin: const EdgeInsets.only(top: 4, bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  report.originalSms,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  void _copyToClipboard(String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      successMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
