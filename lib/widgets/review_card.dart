import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/review_model.dart';
import '../screens/review_detail_screen.dart';
import '../utils/theme.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final moodStyle = getMoodStyle(review.review);
    final formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(review.createdAt);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(() => ReviewDetailScreen(review: review));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: User Name & Mood/Review Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: moodStyle.color.withValues(alpha: 0.15),
                        child: Icon(
                          moodStyle.icon,
                          color: moodStyle.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.name.isNotEmpty ? review.name : 'Anonymous',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (review.mobile.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                review.mobile,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Review Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: moodStyle.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: moodStyle.color.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        moodStyle.icon,
                        size: 14,
                        color: moodStyle.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review.review,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: moodStyle.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Footer Row: Unit badge & Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Unit badge
                if (review.unit != null && review.unit!.name.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          review.unit!.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  const SizedBox.shrink(),

                // Creation Timestamp
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
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
}
