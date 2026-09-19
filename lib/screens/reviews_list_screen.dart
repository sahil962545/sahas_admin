import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/report_controller.dart';
import '../widgets/multi_select_unit_dialog.dart';
import '../widgets/review_card.dart';

class ReviewsListScreen extends StatelessWidget {
  const ReviewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.find<ReportController>();
    final AuthController authController = Get.find<AuthController>();
    final searchController = TextEditingController(text: controller.searchQuery.value);

    searchController.addListener(() {
      controller.searchQuery.value = searchController.text;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reviews & Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Refresh Reviews',
            onPressed: () => controller.fetchReviews(),
          ),
          Obx(() {
            if (authController.isUnitUser) {
              return IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Logout',
                onPressed: () => authController.logout(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchReviews(),
        child: Column(
          children: [
            // 1. Search Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search reviews by name, mobile, review, unit...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          searchController.clear();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            // 2. Multi-Select Unit Selector Bar (Visible for Admin and CO)
            Obx(() {
              if (!authController.isAdmin && !authController.isCo) {
                return const SizedBox.shrink();
              }

              final units = controller.units;
              final selectedIds = controller.selectedUnitIds;

              final String unitText;
              if (selectedIds.isEmpty) {
                unitText = 'All Units (Tap to select multiple)';
              } else if (selectedIds.length == 1) {
                final found = units.firstWhereOrNull((u) => u.id == selectedIds.first);
                unitText = found?.name ?? '1 Unit Selected';
              } else {
                unitText = '${selectedIds.length} Units Selected';
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final result = await showDialog<List<String>>(
                          context: context,
                          builder: (context) => MultiSelectUnitDialog(
                            units: units,
                            initialSelectedIds: selectedIds.toList(),
                          ),
                        );
                        if (result != null) {
                          controller.setSelectedUnitIds(result);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Units Filter:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                unitText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                            if (selectedIds.isNotEmpty) ...[
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                tooltip: 'Clear Unit Filter',
                                onPressed: () => controller.clearUnitSelection(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ] else
                              const Icon(Icons.arrow_drop_down_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 4),

            // 3. Sentiment Choice Chips Bar (Hidden for unit-user)
            Obx(() {
              if (authController.isUnitUser) {
                return const SizedBox.shrink();
              }
              final selected = controller.selectedSentiment.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All Sentiments'),
                        selected: selected.isEmpty,
                        onSelected: (val) {
                          if (val) controller.setSelectedSentiment('');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Happy 😊'),
                        selected: selected == 'happy',
                        selectedColor: const Color(0xFFD1FAE5),
                        onSelected: (val) {
                          if (val) {
                            controller.setSelectedSentiment('happy');
                          } else {
                            controller.setSelectedSentiment('');
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Unhappy 🙁'),
                        selected: selected == 'unhappy',
                        selectedColor: const Color(0xFFFEF3C7),
                        onSelected: (val) {
                          if (val) {
                            controller.setSelectedSentiment('unhappy');
                          } else {
                            controller.setSelectedSentiment('');
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Emergency 🚨'),
                        selected: selected == 'emergency',
                        selectedColor: const Color(0xFFFEE2E2),
                        onSelected: (val) {
                          if (val) {
                            controller.setSelectedSentiment('emergency');
                          } else {
                            controller.setSelectedSentiment('');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 4),

            // 4. Date Filter Presets Bar (All, 2 Days, 7 Days, Custom)
            Obx(() {
              final activePreset = controller.activeDatePreset.value;
              final range = controller.selectedDateRange.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Dates'),
                            selected: activePreset == 'All',
                            onSelected: (selected) {
                              if (selected) controller.clearDateFilter();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Last 2 Days'),
                            selected: activePreset == '2 Days',
                            onSelected: (selected) {
                              if (selected) controller.apply2DaysFilter();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Last 7 Days'),
                            selected: activePreset == '7 Days',
                            onSelected: (selected) {
                              if (selected) controller.apply7DaysFilter();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            avatar: const Icon(Icons.calendar_month_rounded, size: 16),
                            label: Text(activePreset == 'Custom' && range != null
                                ? '${DateFormat('dd MMM').format(range.start)} - ${DateFormat('dd MMM').format(range.end)}'
                                : 'Custom Range'),
                            selected: activePreset == 'Custom',
                            onSelected: (selected) async {
                              final now = DateTime.now();
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(now.year + 5),
                                initialDateRange: range ??
                                    DateTimeRange(
                                      start: now.subtract(const Duration(days: 30)),
                                      end: now,
                                    ),
                              );
                              if (picked != null) {
                                controller.applyCustomDateRange(picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (range != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          'Active Range: ${DateFormat('dd MMM yyyy').format(range.start)} to ${DateFormat('dd MMM yyyy').format(range.end)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // 4. Main Reviews List View
            Expanded(
              child: Obx(() {
                final reviews = controller.filteredReviews;
                final isLoading = controller.isLoading.value;

                if (isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Fetching reviews...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                if (reviews.isEmpty) {
                  return _buildEmptyState(context, controller);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    int crossAxisCount = 1;
                    if (width >= 900) {
                      crossAxisCount = 3;
                    } else if (width >= 600) {
                      crossAxisCount = 2;
                    }

                    if (crossAxisCount > 1) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return ReviewCard(review: reviews[index]);
                        },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return ReviewCard(review: reviews[index]);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportController controller) {
    final hasFilter = controller.searchQuery.value.isNotEmpty ||
        controller.selectedUnitId.value.isNotEmpty ||
        controller.selectedUnitIds.isNotEmpty ||
        controller.selectedDateRange.value != null;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter ? Icons.search_off_rounded : Icons.rate_review_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No Reviews Found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Try adjusting search query, unit selection, or date range.'
                  : 'No reviews found from the server.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchReviews(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
