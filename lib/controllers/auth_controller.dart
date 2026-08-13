import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../controllers/report_controller.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString adminName = ''.obs;
  final RxString adminRole = ''.obs;
  final RxString userUnit = ''.obs;

  /// Returns true if the logged in user has the admin role.
  bool get isAdmin => adminRole.value.trim().toLowerCase() == 'admin';

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  /// Check token existence on app startup to auto-login or redirect to login.
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        isAuthenticated.value = true;
        adminName.value = await _authService.getName() ?? 'Admin';
        adminRole.value = await _authService.getRole() ?? 'admin';
        userUnit.value = await _authService.getUnit() ?? '';
        // Go to main navigation screen
        Get.offAll(() => const MainNavigationScreen());
      } else {
        isAuthenticated.value = false;
        // Go to login screen
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      isAuthenticated.value = false;
      Get.offAll(() => const LoginScreen());
    }
  }

  /// Perform login action.
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _authService.login(email.trim(), password.trim());
      
      isAuthenticated.value = true;
      final data = result['data'];
      adminName.value = data['name'] ?? 'Admin';
      adminRole.value = data['role'] ?? 'admin';
      userUnit.value = data['unit']?.toString() ?? '';

      Get.snackbar(
        'Success',
        result['message'] ?? 'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to main navigation screen
      Get.offAll(() => const MainNavigationScreen());
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Log out from the app, clearing credentials and cached data.
  Future<void> logout() async {
    isLoading.value = true;
    try {
      // 1. Clear secure storage
      await _authService.logout();
      isAuthenticated.value = false;
      adminName.value = '';
      adminRole.value = '';
      userUnit.value = '';

      // 2. Clear reports in memory & Hive cache if ReportController was initialized
      if (Get.isRegistered<ReportController>()) {
        await Get.find<ReportController>().clearAllData();
      }

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 3. Navigate back to Login screen
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout correctly: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
