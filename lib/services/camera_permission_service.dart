import 'package:permission_handler/permission_handler.dart';

/// カメラ権限管理サービス
class CameraPermissionService {
  /// カメラ権限の状態を取得
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// カメラ権限をリクエスト
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// カメラ権限が許可されているかチェック
  Future<bool> isCameraPermissionGranted() async {
    final status = await getCameraPermissionStatus();
    return status == PermissionStatus.granted;
  }

  /// カメラ権限が永続的に拒否されているかチェック
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await getCameraPermissionStatus();
    return status == PermissionStatus.permanentlyDenied;
  }

  /// カメラ権限を確認し、必要に応じてリクエスト
  Future<CameraPermissionResult> ensureCameraPermission() async {
    // 現在の権限状態を確認
    PermissionStatus status = await getCameraPermissionStatus();

    switch (status) {
      case PermissionStatus.granted:
        return CameraPermissionResult.granted;

      case PermissionStatus.denied:
        // 権限をリクエスト
        status = await requestCameraPermission();
        if (status == PermissionStatus.granted) {
          return CameraPermissionResult.granted;
        } else if (status == PermissionStatus.permanentlyDenied) {
          return CameraPermissionResult.permanentlyDenied;
        } else {
          return CameraPermissionResult.denied;
        }

      case PermissionStatus.permanentlyDenied:
        return CameraPermissionResult.permanentlyDenied;

      case PermissionStatus.restricted:
        return CameraPermissionResult.restricted;

      default:
        return CameraPermissionResult.denied;
    }
  }

  /// 設定画面を開く
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}

/// カメラ権限の結果
enum CameraPermissionResult {
  /// 権限が許可された
  granted,

  /// 権限が拒否された
  denied,

  /// 権限が永続的に拒否された（設定画面での変更が必要）
  permanentlyDenied,

  /// 権限が制限されている（ペアレンタルコントロールなど）
  restricted,
}

/// カメラ権限に関する例外
class CameraPermissionException implements Exception {
  final String message;
  final CameraPermissionResult result;

  const CameraPermissionException(this.message, this.result);

  @override
  String toString() => 'CameraPermissionException: $message';
}
