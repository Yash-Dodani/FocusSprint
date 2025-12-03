// lib/services/permission_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> ensureNotificationPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;

    final status = await Permission.notification.status;

    if (status.isDenied || status.isRestricted) {
      await Permission.notification.request();
    }
  }
}
