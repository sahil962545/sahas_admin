import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/report_controller.dart';
import '../utils/theme.dart';
import '../widgets/review_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.isRegistered<ReportController>()
        ? Get.find<ReportController>()
        : Get.put(ReportController());
    final AuthController authController = Get.find<AuthController>();
    final searchController = TextEditingController();

    // Sync search input controller with GetX state
    searchController.addListener(() {
      controller.searchQuery.value = searchController.text;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BHAROSA ADMIN',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              if (Get.isDarkMode) {
                Get.changeTheme(AppTheme.lightTheme);
              } else {
                Get.changeTheme(AppTheme.darkTheme);
              }
            },
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Refresh Reviews',
            onPressed: () => controller.fetchReviews(),
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              // Confirm logout dialog
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      child: const Text('Logout',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header Section
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

          // Admin Unit Selector Bar (Visible ONLY if role is admin)
          Obx(() {
            if (!authController.isAdmin) {
              return const SizedBox.shrink();
            }

            final units = controller.units;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Unit Filter:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedUnitId.value,
                          isExpanded: true,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('All Units'),
                            ),
                            ...units.map((u) => DropdownMenuItem<String>(
                                  value: u.id,
                                  child: Text(u.name),
                                )),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.setSelectedUnitId(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 4),

          // Date Range Selector Bar
          Obx(() {
            final range = controller.selectedDateRange.value;
            final String dateText;
            if (range != null) {
              final startStr = DateFormat('dd MMM yyyy').format(range.start);
              final endStr = DateFormat('dd MMM yyyy').format(range.end);
              dateText = '$startStr - $endStr';
            } else {
              dateText = 'All Dates (Tap to select range)';
            }

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
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
                        controller.setDateRange(picked);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dateText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                          if (range != null) ...[
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              tooltip: 'Clear Date Filter',
                              onPressed: () => controller.setDateRange(null),
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

          // Main Cloud Reviews List Area
          Expanded(
            child: Obx(() {
              final reviews = controller.filteredReviews;
              final isLoading = controller.isLoading.value;

              // Prominent Circular Progress Indicator when data changes/loading
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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

              return RefreshIndicator(
                onRefresh: () => controller.fetchReviews(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    // Responsive columns logic for larger screens
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
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportController controller) {
    final hasFilter = controller.searchQuery.value.isNotEmpty ||
        controller.selectedUnitId.value.isNotEmpty ||
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
              size: 72,
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No Reviews Found' : 'No Reviews Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try adjusting your search query, unit selection, or date range.'
                  : 'We couldn\'t find any reviews from the cloud server.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.fetchReviews(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh Reviews'),
            ),
          ],
        ),
      ),
    );
  }
}
