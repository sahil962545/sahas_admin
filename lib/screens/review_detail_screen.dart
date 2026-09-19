import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/report_controller.dart';
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    final ReportController controller = Get.find<ReportController>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 10),
              const Text('Delete Review', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this review?\n\nThis action will send a delete request and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            Obx(() {
              final isDeleting = controller.isDeletingReview.value;
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isDeleting
                    ? null
                    : () async {
                        final success = await controller.deleteReview(review.id);
                        if (success && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(); // Dismiss dialog
                          if (context.mounted) {
                            Navigator.of(context).pop(); // Return to reviews list
                          }
                        }
                      },
                icon: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_forever_rounded),
                label: Text(isDeleting ? 'Deleting...' : 'Delete'),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodStyle = getMoodStyle(
        review.sentiment.isNotEmpty ? review.sentiment : review.review);
    final theme = Theme.of(context);
    final formattedDate =
        DateFormat('dd MMMM yyyy, hh:mm:ss a').format(review.createdAt);

    final displayName = review.name.isNotEmpty
        ? review.name
        : (review.unit != null && review.unit!.name.isNotEmpty
            ? 'Unit ${review.unit!.name}'
            : 'Anonymous User');

    final displaySentiment = review.formattedSentiment.isNotEmpty
        ? review.formattedSentiment
        : (review.review.isNotEmpty ? review.review : 'Review');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() {
            if (Get.isRegistered<AuthController>() &&
                !Get.find<AuthController>().canDeleteReviews) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete Review',
              color: theme.colorScheme.error,
              onPressed: () => _showDeleteConfirmationDialog(context),
            );
          }),
        ],
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
                      displayName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
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
                          Icon(moodStyle.icon,
                              size: 18, color: moodStyle.color),
                          const SizedBox(width: 6),
                          Text(
                            displaySentiment,
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
                    // Review Comment Row
                    _buildDetailRow(
                      context,
                      icon: Icons.rate_review_rounded,
                      label: 'Review Comment',
                      value: review.review.isNotEmpty
                          ? '"${review.review}"'
                          : 'N/A',
                      onCopy: review.review.isNotEmpty
                          ? () => _copyToClipboard(
                              review.review, 'Review comment copied')
                          : null,
                    ),
                    const Divider(height: 24),

                    // Sentiment Row
                    _buildDetailRow(
                      context,
                      icon: Icons.emoji_emotions_rounded,
                      label: 'Sentiment',
                      value: displaySentiment,
                    ),
                    const Divider(height: 24),

                    // Unit Name Row
                    _buildDetailRow(
                      context,
                      icon: Icons.business_rounded,
                      label: 'Unit Name',
                      value: review.unit?.name.isNotEmpty == true
                          ? 'Unit ${review.unit!.name}'
                          : 'N/A',
                    ),
                    const Divider(height: 24),

                    // Mobile Number Row
                    // _buildDetailRow(
                    //   context,
                    //   icon: Icons.phone_rounded,
                    //   label: 'Mobile Number',
                    //   value: review.mobile.isNotEmpty ? review.mobile : 'N/A',
                    //   onCopy: review.mobile.isNotEmpty
                    //       ? () => _copyToClipboard(review.mobile, 'Mobile number copied')
                    //       : null,
                    // ),
                    // const Divider(height: 24),

                    // Created At Timestamp Row
                    _buildDetailRow(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: 'Submitted At',
                      value: formattedDate,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: 'Copy',
            onPressed: onCopy,
          ),
      ],
    );
  }
}
