import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/report_controller.dart';
import '../models/dashboard_model.dart';
import '../widgets/dashboard_chart_card.dart';
import '../widgets/unit_sentiment_bar_chart_card.dart';
import 'change_password_screen.dart';
import 'reviews_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.isRegistered<ReportController>()
        ? Get.find<ReportController>()
        : Get.put(ReportController());
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'SMILE ADMIN',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          /*
          // Theme Toggle Button
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () {
              if (Get.isDarkMode) {
                Get.changeTheme(AppTheme.lightTheme);
              } else {
                // Get.changeTheme(AppTheme.darkTheme);
              }
            },
          ),
          */
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Refresh Dashboard',
            onPressed: () {
              controller.fetchDashboard();
              controller.fetchReviews();
            },
          ),
          // Change Password Button (Hidden for CO role)
          Obx(() {
            if (!authController.canChangePassword) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.lock_reset_rounded),
              tooltip: 'Change Password',
              onPressed: () {
                Get.to(() => const ChangePasswordScreen());
              },
            );
          }),
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.fetchDashboard(),
            controller.fetchReviews(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dashboard Filters Card (Unit, Sentiment, Date Range)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_alt_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Dashboard Filters',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // A. Single-Select Unit Filter Dropdown (Admin & CO)
                        Obx(() {
                          if (!authController.isAdmin && !authController.isCo) {
                            return const SizedBox.shrink();
                          }


                          final units = controller.units;
                          final selectedId = controller.selectedUnitId.value;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: DropdownButtonFormField<String>(
                              value: selectedId.isEmpty ? '' : selectedId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Filter Unit',
                                prefixIcon: Icon(
                                  Icons.business_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('All Units'),
                                ),
                                ...units.map((unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit.id,
                                    child: Text(unit.name),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                controller.setSelectedUnitId(val ?? '');
                              },
                            ),
                          );
                        }),

                        // B. Sentiment Choice Chips Bar
                        Obx(() {
                          final selected = controller.selectedSentiment.value;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('All Sentiments'),
                                  selected: selected.isEmpty,
                                  onSelected: (val) {
                                    if (val) {
                                      controller.setSelectedSentiment('');
                                    }
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
                                      controller
                                          .setSelectedSentiment('unhappy');
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
                                      controller
                                          .setSelectedSentiment('emergency');
                                    } else {
                                      controller.setSelectedSentiment('');
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 8),

                        // C. Date Preset Choice Chips Bar
                        Obx(() {
                          final activePreset =
                              controller.activeDatePreset.value;
                          final range = controller.selectedDateRange.value;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('All Dates'),
                                  selected: activePreset == 'All',
                                  onSelected: (val) {
                                    if (val) controller.clearDateFilter();
                                  },
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('2 Days'),
                                  selected: activePreset == '2 Days',
                                  onSelected: (val) {
                                    if (val) controller.apply2DaysFilter();
                                  },
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('7 Days'),
                                  selected: activePreset == '7 Days',
                                  onSelected: (val) {
                                    if (val) controller.apply7DaysFilter();
                                  },
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  avatar: const Icon(
                                      Icons.calendar_month_rounded,
                                      size: 14),
                                  label: Text(activePreset == 'Custom' &&
                                          range != null
                                      ? '${DateFormat('dd MMM').format(range.start)} - ${DateFormat('dd MMM').format(range.end)}'
                                      : 'Custom Range'),
                                  selected: activePreset == 'Custom',
                                  onSelected: (val) async {
                                    final now = DateTime.now();
                                    final picked = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(now.year + 5),
                                      initialDateRange: range ??
                                          DateTimeRange(
                                            start: now.subtract(
                                                const Duration(days: 30)),
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
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // 1. Dashboard Overview Graph Card
              Obx(() {
                final dashboard = controller.dashboardData.value;
                final isLoading = controller.isLoadingDashboard.value;

                if (dashboard == null && !isLoading) {
                  return const SizedBox.shrink();
                }

                return DashboardChartCard(
                  dashboard: dashboard ??
                      const DashboardModel(
                          happy: 0, unhappy: 0, emergency: 0, total: 0),
                  isLoading: isLoading,
                  onTap: () {
                    Get.to(() => const ReviewsListScreen());
                  },
                  onSentimentTap: (sentiment) {
                    controller.setSelectedSentiment(sentiment);
                    Get.to(() => const ReviewsListScreen());
                  },
                );
              }),

              // 2. Unit Sentiment Breakdown Grouped Bar Chart Card
              Obx(() {
                final dashboard = controller.dashboardData.value;
                final isLoading = controller.isLoadingDashboard.value;

                if (dashboard == null && !isLoading) {
                  return const SizedBox.shrink();
                }

                return UnitSentimentBarChartCard(
                  units: dashboard?.units ?? [],
                  isLoading: isLoading,
                  onUnitSentimentTap: (unitId, sentiment) {
                    controller.setSelectedUnitId(unitId);
                    if (sentiment.isNotEmpty) {
                      controller.setSelectedSentiment(sentiment);
                    }
                    Get.to(() => const ReviewsListScreen());
                  },
                );
              }),

              const SizedBox(height: 12),

              // Dedicated Full-Width Navigation Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const ReviewsListScreen());
                    },
                    icon: const Icon(Icons.list_alt_rounded, size: 22),
                    label: const Text(
                      'View All Reviews & Search',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
