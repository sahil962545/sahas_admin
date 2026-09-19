import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  final UserService _userService = Get.put(UserService());

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

  // Search & Pagination Observables
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt limit = 10.obs;
  final RxInt totalCount = 0.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();

    // Debounce search query changes by 500ms before calling API
    // Calls search API only when search query is empty (reset) or length >= 3 characters
    debounce(
      searchQuery,
      (query) {
        final trimmed = query.trim();
        if (trimmed.isEmpty || trimmed.length >= 3) {
          fetchUsers(reset: true);
        }
      },
      time: const Duration(milliseconds: 500),
    );

    // Initial fetch
    fetchUsers(reset: true);
  }

  void onSearchQueryChanged(String query) {
    searchQuery.value = query;
  }

  /// Fetch users from API matching current page, limit, and debounced search query.
  /// If [reset] is true, resets to page 1 and replaces the list.
  /// If [isLoadMore] is true, appends results to the existing list.
  Future<void> fetchUsers({bool reset = false, bool isLoadMore = false}) async {
    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      isLoading.value = true;
    } else if (isLoadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final result = await _userService.fetchUsers(
        page: currentPage.value,
        limit: limit.value,
        search: searchQuery.value,
      );

      if (isLoadMore) {
        users.addAll(result.users);
      } else {
        users.assignAll(result.users);
      }

      totalCount.value = result.totalCount;
      totalPages.value = result.totalPages > 0 ? result.totalPages : 1;

      // Determine if there are more pages left
      if (result.users.isEmpty || currentPage.value >= totalPages.value) {
        hasMore.value = false;
      } else {
        hasMore.value = true;
      }
    } catch (e) {
      debugPrint('Error loading users in controller: $e');
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load next page when scrolling near maxScrollExtent (Instagram style)
  Future<void> loadMoreUsers() async {
    if (hasMore.value && !isLoading.value && !isLoadingMore.value) {
      currentPage.value++;
      await fetchUsers(isLoadMore: true);
    }
  }

  /// Clear Search Query
  void clearSearch() {
    searchQuery.value = '';
    fetchUsers(reset: true);
  }

  /// Refresh users list manually
  Future<void> refreshUsers() async {
    await fetchUsers(reset: true);
  }

  final RxBool isResettingPassword = false.obs;
  final RxBool isUpdatingUser = false.obs;
  final RxBool isDeletingUser = false.obs;

  /// Reset password for a target user ID
  Future<bool> resetUserPassword(String userId, String newPassword) async {
    try {
      isResettingPassword.value = true;
      final res = await _userService.resetUserPassword(
        userId: userId,
        newPassword: newPassword,
      );
      Get.snackbar(
        'Success',
        res['message'] ?? 'Password reset successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Reset Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isResettingPassword.value = false;
    }
  }

  /// Update user details by ID
  Future<bool> updateUser(String userId, Map<String, dynamic> updateData) async {
    try {
      isUpdatingUser.value = true;
      final res = await _userService.updateUser(
        userId: userId,
        updateData: updateData,
      );
      Get.snackbar(
        'Success',
        res['message'] ?? 'User updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      await refreshUsers();
      return true;
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isUpdatingUser.value = false;
    }
  }

  /// Delete user by ID
  Future<bool> deleteUser(String userId) async {
    try {
      isDeletingUser.value = true;
      final res = await _userService.deleteUser(userId: userId);
      Get.snackbar(
        'Success',
        res['message'] ?? 'User deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
      users.removeWhere((u) => u.id == userId);
      await refreshUsers();
      return true;
    } catch (e) {
      Get.snackbar(
        'Delete Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isDeletingUser.value = false;
    }
  }
}

