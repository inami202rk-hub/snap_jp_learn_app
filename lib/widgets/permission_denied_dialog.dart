import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_jp_learn_app/l10n/strings_en.dart';

/// Dialog shown when camera or photo permission is denied
class PermissionDeniedDialog extends StatelessWidget {
  final String title;
  final String message;
  final Permission permission;

  const PermissionDeniedDialog({
    super.key,
    required this.title,
    required this.message,
    required this.permission,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _openAppSettings();
          },
          child: Text(AppStrings.openSettings),
        ),
      ],
    );
  }

  void _openAppSettings() {
    openAppSettings();
  }

  /// Show camera permission denied dialog
  static void showCameraPermissionDenied(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PermissionDeniedDialog(
        title: AppStrings.cameraPermissionDeniedTitle,
        message: AppStrings.cameraPermissionDeniedMessage,
        permission: Permission.camera,
      ),
    );
  }

  /// Show photo library permission denied dialog
  static void showPhotoPermissionDenied(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PermissionDeniedDialog(
        title: AppStrings.photoPermissionDeniedTitle,
        message: AppStrings.photoPermissionDeniedMessage,
        permission: Permission.photos,
      ),
    );
  }
}
