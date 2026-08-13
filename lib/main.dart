import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/report_controller.dart';
import 'repository/report_repository.dart';
import 'services/auth_service.dart';
import 'services/review_service.dart';
import 'services/sms_service.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local cache storage (Hive)
  final storageService = Get.put(StorageService());
  await storageService.init();

  // 2. Register authentication & review services and controller first
  Get.put(AuthService());
  Get.put(ReviewService());
  Get.put(AuthController());

  // 3. Register other services and repositories
  Get.put(SmsService());
  Get.put(
    ReportRepository(
      smsService: Get.find<SmsService>(),
      storageService: Get.find<StorageService>(),
    ),
  );

  // 4. Register state controller lazily with fenix so it persists across offAll navigation
  Get.lazyPut(() => ReportController(), fenix: true);

  runApp(const BharosaAdminApp());
}

class BharosaAdminApp extends StatelessWidget {
  const BharosaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BHAROSA Admin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Forces white light theme by default
      home: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
