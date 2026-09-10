// lib/services/permission_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PermissionService — request and check storage/photo permissions
// ─────────────────────────────────────────────────────────────────────────────

class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  /// Request storage permission needed to save files to Downloads.
  /// Returns true if permission granted, false if denied.
  Future<bool> requestStoragePermission() async {
    // iOS — no storage permission needed
    if (Platform.isIOS) return true;

    // Android 13+ (API 33+) — use granular media permissions
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        // Android 13+ — only need photos permission for image tools
        final status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      } else {
        // Android < 13 — classic storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }

    return true;
  }

  /// Check if storage permission is already granted (no dialog).
  Future<bool> hasStoragePermission() async {
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        return await Permission.photos.isGranted ||
            await Permission.photos.isLimited;
      } else {
        return await Permission.storage.isGranted;
      }
    }

    return true;
  }

  /// Show a dialog explaining why the permission is needed,
  /// then redirect to app settings if permanently denied.
  Future<void> showPermissionDeniedDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.folder_off_rounded, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Text('Permission Required',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'ConvertIt needs storage access to save converted files '
          'to your Downloads folder.\n\n'
          'Please enable storage permission in App Settings.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns Android SDK version number, or 0 on non-Android.
  Future<int> _getAndroidVersion() async {
    try {
      // Use ProcessResult to read the SDK int from the system property
      final result = await Process.run(
          'getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}