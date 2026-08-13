import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/review_model.dart';
import '../utils/theme.dart';

class ReviewDetailScreen extends StatelessWidget {
  final ReviewModel review;

  const ReviewDetailScreen({super.key, required this.review});

  void _copyToClipboard(String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      successMessage,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodStyle = getMoodStyle(review.review);
    final theme = Theme.of(context);
    final formattedDate = DateFormat('dd MMMM yyyy, hh:mm:ss a').format(review.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: moodStyle.color.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: moodStyle.color.withValues(alpha: 0.15),
                      child: Icon(
                        moodStyle.icon,
                        color: moodStyle.color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review.name.isNotEmpty ? review.name : 'Anonymous',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: moodStyle.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: moodStyle.color.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(moodStyle.icon, size: 18, color: moodStyle.color),
                          const SizedBox(width: 6),
                          Text(
                            review.review,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: moodStyle.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Detail Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Mobile Number Row
                    _buildDetailRow(
                      context,
                      icon: Icons.phone_rounded,
                      label: 'Mobile Number',
                      value: review.mobile.isNotEmpty ? review.mobile : 'N/A',
                      onCopy: review.mobile.isNotEmpty
                          ? () => _copyToClipboard(review.mobile, 'Mobile number copied')
                          : null,
                    ),
                    const Divider(height: 24),

                    // Unit Name Row
                    _buildDetailRow(
                      context,
                      icon: Icons.business_rounded,
                      label: 'Unit Name',
                      value: review.unit?.name ?? 'N/A',
                    ),
                    const Divider(height: 24),

                    // Created At Timestamp Row
                    _buildDetailRow(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: 'Submitted At',
                      value: formattedDate,
                    ),
                    const Divider(height: 24),

                    // Record ID Row
                    _buildDetailRow(
                      context,
                      icon: Icons.fingerprint_rounded,
                      label: 'Record ID',
                      value: review.id,
                      onCopy: () => _copyToClipboard(review.id, 'Record ID copied'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: onCopy,
            tooltip: 'Copy',
          ),
      ],
    );
  }
}
