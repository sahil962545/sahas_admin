import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import 'package:another_telephony/telephony.dart';
import '../models/review_model.dart';
import '../models/sahas_report.dart';
import '../models/unit_model.dart';
import '../repository/report_repository.dart';
import '../services/review_service.dart';
import '../services/sms_service.dart';

class ReportController extends GetxController {
  final SmsService _smsService = Get.find<SmsService>();
  final ReportRepository _reportRepository = Get.find<ReportRepository>();

  // Cloud Reviews & Units Observables
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxList<UnitModel> units = <UnitModel>[].obs;
  final RxString selectedUnitId = ''.obs;
  final RxBool isLoadingUnits = false.obs;

  // State Observables
  final RxList<SahasReport> reports = <SahasReport>[].obs;
  final RxBool hasPermission = false.obs;
  final RxBool isPermanentlyDenied = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter & Search Observables
  final RxString searchQuery = ''.obs;
  final Rxn<DateTimeRange> selectedDateRange = Rxn<DateTimeRange>();

  @override
  void onInit() {
    super.onInit();
    
    // Listen for filter changes and trigger API re-fetch automatically
    ever(selectedUnitId, (_) => fetchReviews());
    ever(selectedDateRange, (_) => fetchReviews());

    // Initial data fetch
    hasPermission.value = true;
    fetchUnits();
    fetchReviews();
  }

  /// Fetch Units list from API (Only for Admin role)
  Future<void> fetchUnits() async {
    try {
      isLoadingUnits.value = true;
      if (Get.isRegistered<AuthController>()) {
        final authCtrl = Get.find<AuthController>();
        if (!authCtrl.isAdmin) {
          units.clear();
          return;
        }
      }
      if (Get.isRegistered<ReviewService>()) {
        final fetchedUnits = await Get.find<ReviewService>().fetchUnits();
        units.assignAll(fetchedUnits);
      }
    } catch (e) {
      debugPrint('Error loading units in controller: $e');
    } finally {
      isLoadingUnits.value = false;
    }
  }

  /// Fetch Reviews from API matching selected unit and date range filters
  Future<void> fetchReviews() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      String? fromDateStr;
      String? toDateStr;

      final range = selectedDateRange.value;
      if (range != null) {
        fromDateStr = range.start.toIso8601String().split('T')[0];
        toDateStr = range.end.toIso8601String().split('T')[0];
      }

      if (Get.isRegistered<ReviewService>()) {
        final fetchedReviews = await Get.find<ReviewService>().fetchReviews(
          page: 1,
          unitId: selectedUnitId.value,
          fromDate: fromDateStr,
          toDate: toDateStr,
        );
        reviews.assignAll(fetchedReviews);
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch reviews: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Set selected unit filter ID and fetch reviews
  void setSelectedUnitId(String unitId) {
    selectedUnitId.value = unitId;
    fetchReviews();
  }

  /// Set custom date range filter and fetch reviews
  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    fetchReviews();
  }

  /// Filtered list of reviews based on search query
  List<ReviewModel> get filteredReviews {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return reviews;
    }

    return reviews.where((r) {
      final nameMatch = r.name.toLowerCase().contains(query);
      final mobileMatch = r.mobile.toLowerCase().contains(query);
      final reviewMatch = r.review.toLowerCase().contains(query);
      final unitMatch = r.unit?.name.toLowerCase().contains(query) ?? false;
      return nameMatch || mobileMatch || reviewMatch || unitMatch;
    }).toList();
  }

  /// Initial entry point: Check permission and initialize data
  Future<void> checkPermissionsAndInitialize() async {
    if (!Platform.isAndroid) {
      errorMessage.value =
          'SMS features are only supported on Android devices.';
      return;
    }

    try {
      isLoading.value = true;
      final bool granted = await _smsService.checkPermissionStatus();
      hasPermission.value = granted;

      if (granted) {
        // Load whatever is in Hive cache first for fast start
        _loadCachedReports();
        // Sync with inbox to catch up on any reports received while app was closed
        await syncReports();
        // Register foreground listener for incoming reports
        _startIncomingSmsListener();
      } else {
        // Check if permanently denied to guide user to settings
        isPermanentlyDenied.value = await _smsService
            .isPermissionPermanentlyDenied();
      }
    } catch (e) {
      errorMessage.value = 'Failed during initialization: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Requests SMS permission from the user
  Future<void> requestPermissions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final bool granted = await _smsService.requestSmsPermission();
      hasPermission.value = granted;

      if (granted) {
        isPermanentlyDenied.value = false;
        _loadCachedReports();
        await syncReports();
        _startIncomingSmsListener();
        Get.snackbar(
          'Permissions Granted',
          'SMS reading and receiving initialized successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        isPermanentlyDenied.value = await _smsService
            .isPermissionPermanentlyDenied();
        if (isPermanentlyDenied.value) {
          Get.snackbar(
            'Permissions Denied',
            'SMS permission permanently denied. Please enable it from application settings.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Permissions Required',
            'This application needs SMS permissions to read and monitor BHAROSA safety reports.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to request permission: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Open application settings page
  Future<void> openAppSettings() async {
    await _smsService.openSettings();
  }

  /// Load reports cached in Hive database
  void _loadCachedReports() {
    final cached = _reportRepository.getCachedReports();
    reports.assignAll(cached);
  }

  /// Syncs device inbox with Hive cache and updates reports list
  Future<void> syncReports() async {
    if (!hasPermission.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final synced = await _reportRepository.syncInboxReports();
      reports.assignAll(synced);
    } catch (e) {
      errorMessage.value = 'Error reading SMS inbox: $e';
      Get.snackbar(
        'Inbox Sync Error',
        'Could not query device inbox. Please check device permissions.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sets up listener to automatically intercept incoming SMS
  void _startIncomingSmsListener() {
    _smsService.startListening((SmsMessage message) {
      _processIncomingSms(message);
    });
  }

  /// Process incoming SMS (for live updates)
  Future<void> _processIncomingSms(SmsMessage message) async {
    final body = message.body ?? '';
    final sender = message.address ?? 'Unknown';
    final timestamp = message.date ?? DateTime.now().millisecondsSinceEpoch;

    // Only process if it matches prefix
    final cleanBody = body.trim().toLowerCase();
    if (!cleanBody.startsWith('sahas|') && !cleanBody.startsWith('sahas-')) {
      return;
    }

    final uniqueId = '${timestamp}_${sender}_${body.trim()}';

    // Duplicate Prevention: check if we already have it in memory
    final alreadyExists = reports.any((report) => report.id == uniqueId);
    if (alreadyExists) return;

    try {
      // Parse report
      final report = SahasReport.fromSms(body, sender, timestamp);

      // Cache locally
      await _reportRepository.saveReport(report);

      // Prepend to list instantly (satisfies: "Insert at the top of the list instantly. No manual refresh required.")
      reports.insert(0, report);

      Get.snackbar(
        'New Report Received',
        'From ${report.employeeName} (${report.mood})',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('Failed parsing incoming report SMS: $e');
    }
  }

  /// List of reports filtered by search query, mood and date filters
  List<SahasReport> get filteredReports {
    return reports.where((report) {
      // 1. Search Query Filter (Name, Phone Number, Remarks)
      final query = searchQuery.value.trim().toLowerCase();
      if (query.isNotEmpty) {
        final nameMatch = report.employeeName.toLowerCase().contains(query);
        final phoneMatch = report.phoneNumber.toLowerCase().contains(query);
        final remarksMatch = report.remarks.toLowerCase().contains(query);
        if (!nameMatch && !phoneMatch && !remarksMatch) {
          return false;
        }
      }

      // 3. Date Filter
      final range = selectedDateRange.value;
      if (range != null) {
        if (report.receivedTime.isBefore(range.start) ||
            report.receivedTime.isAfter(range.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // --- Statistics Getters ---

  int get totalReportsCount => reports.length;

  int get happyReportsCount =>
      reports.where((r) => r.mood.trim().toLowerCase() == 'happy').length;

  int get normalReportsCount =>
      reports.where((r) => r.mood.trim().toLowerCase() == 'normal').length;

  int get sadReportsCount =>
      reports.where((r) => r.mood.trim().toLowerCase() == 'sad').length;

  int get sickReportsCount =>
      reports.where((r) => r.mood.trim().toLowerCase() == 'sick').length;

  int get emergencyReportsCount =>
      reports.where((r) => r.mood.trim().toLowerCase() == 'emergency').length;

  /// Reports received today (current calendar day)
  int get reportsTodayCount {
    final now = DateTime.now();
    return reports.where((r) {
      final t = r.receivedTime;
      return t.year == now.year && t.month == now.month && t.day == now.day;
    }).length;
  }

  /// Reports received this calendar week (from Monday 00:00:00 to now)
  int get reportsThisWeekCount {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return reports.where((r) {
      return r.receivedTime.isAfter(startOfWeekDay) ||
          r.receivedTime.isAtSameMomentAs(startOfWeekDay);
    }).length;
  }

  /// Reset Hive cache and memory state
  Future<void> clearAllData() async {
    await _reportRepository.clearCache();
    reports.clear();
  }
}
