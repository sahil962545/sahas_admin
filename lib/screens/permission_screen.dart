import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.find<ReportController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icon with beautiful gradient effect or rounded background
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sms_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'SMS Permission Required',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final isDenied = controller.isPermanentlyDenied.value;
                return Text(
                  isDenied
                      ? 'SMS permissions have been permanently denied. To receive employee safety reports, please manually enable them in the System Settings under App Info > Permissions.'
                      : 'The BHAROSA Admin application reads incoming SMS messages and filters employee safety reports.\n\nSince this application works entirely offline with no internet access, it depends on device permissions to scan incoming messages and show reports on your dashboard.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                );
              }),
              const Spacer(),
              // Dynamic button based on permanent denial state
              Obx(() {
                final isDenied = controller.isPermanentlyDenied.value;
                final isLoading = controller.isLoading.value;

                return ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (isDenied) {
                            controller.openAppSettings();
                          } else {
                            controller.requestPermissions();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(isDenied ? Icons.settings : Icons.security),
                  label: Text(
                    isLoading
                        ? 'Processing...'
                        : (isDenied ? 'Open Settings' : 'Grant Permissions'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              // Optional manual retry check button
              Obx(() {
                if (controller.isPermanentlyDenied.value) {
                  return TextButton(
                    onPressed: () {
                      controller.checkPermissionsAndInitialize();
                    },
                    child: const Text('I\'ve enabled it, check permission again'),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
