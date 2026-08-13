import 'dart:io';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final Telephony _telephony = Telephony.instance;

  /// Check if SMS permissions are granted
  Future<bool> checkPermissionStatus() async {
    if (!Platform.isAndroid) return false;
    return await Permission.sms.isGranted;
  }

  /// Request SMS permissions
  Future<bool> requestSmsPermission() async {
    if (!Platform.isAndroid) return false;
    
    // Request permission from permission_handler
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied() async {
    if (!Platform.isAndroid) return false;
    return await Permission.sms.isPermanentlyDenied;
  }

  /// Open app settings page so user can grant permission manually
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Fetch all inbox SMS messages
  Future<List<SmsMessage>> fetchInboxSms() async {
    if (!Platform.isAndroid) return [];
    
    try {
      final isGranted = await checkPermissionStatus();
      if (!isGranted) {
        throw Exception('SMS permission not granted');
      }

      // Query inbox with desc date sorting
      final List<SmsMessage> messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );
      return messages;
    } catch (e) {
      print("Error fetching inbox SMS: $e");
      rethrow;
    }
  }

  /// Listen for incoming messages in foreground
  void startListening(Function(SmsMessage message) onMessageReceived) {
    if (!Platform.isAndroid) return;

    try {
      _telephony.listenIncomingSms(
        onNewMessage: onMessageReceived,
      );
    } catch (e) {
      print("Error starting SMS listener: $e");
    }
  }
}
