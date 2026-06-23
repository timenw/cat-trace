/// 权限请求工具类
///
/// 封装了猫迹 App 中常用的系统权限请求逻辑，基于 `permission_handler` 包。
/// 涵盖以下权限：
///   - 相机权限（用于拍照记录猫咪）
///   - 存储权限（用于保存和读取照片）
///   - 通知权限（用于投喂和健康提醒）
///   - 位置权限（用于记录发现位置）
///
/// 使用方式：
/// ```dart
/// final granted = await PermissionUtils.requestCameraPermission();
/// if (granted) {
///   // 打开相机
/// }
/// ```
library permission_utils;

import 'package:permission_handler/permission_handler.dart';

/// 权限请求结果枚举
///
/// 对 permission_handler 的结果进行语义化封装，
/// 方便业务层根据不同结果做出相应处理。
enum PermissionResult {
  /// 权限已授予
  granted,

  /// 权限被拒绝（但可再次请求）
  denied,

  /// 权限被永久拒绝（需要引导用户到设置页面手动开启）
  permanentlyDenied,

  /// 权限被限制（如家长控制等系统限制）
  restricted,

  /// 权限状态未知
  unknown,
}

/// 权限请求工具类
///
/// 所有方法均为静态方法，无需实例化。
class PermissionUtils {
  PermissionUtils._();

  // ==================== 相机权限 ====================

  /// 请求相机权限
  ///
  /// 用于拍照记录猫咪的场景。
  ///
  /// 返回值：
  ///   - `PermissionResult.granted` — 权限已授予，可以打开相机
  ///   - `PermissionResult.denied` — 权限被拒绝，可再次请求
  ///   - `PermissionResult.permanentlyDenied` — 权限被永久拒绝，需引导用户到设置页面
  ///
  /// 使用示例：
  /// ```dart
  /// final result = await PermissionUtils.requestCameraPermission();
  /// switch (result) {
  ///   case PermissionResult.granted:
  ///     // 打开相机
  ///     break;
  ///   case PermissionResult.permanentlyDenied:
  ///     // 引导用户到设置页面
  ///     await openAppSettings();
  ///     break;
  ///   default:
  ///     // 提示用户权限被拒绝
  ///     break;
  /// }
  /// ```
  static Future<PermissionResult> requestCameraPermission() async {
    return _requestPermission(Permission.camera);
  }

  // ==================== 存储权限 ====================

  /// 请求存储权限
  ///
  /// 用于保存和读取照片的场景。
  /// 在 Android 13+ 上，存储权限细分为图片、视频、音频等，
  /// 此处使用 `Permission.photos` 请求图片访问权限。
  ///
  /// 返回值同 [requestCameraPermission]。
  static Future<PermissionResult> requestStoragePermission() async {
    // Android 13+ 使用 photos 权限，低版本使用 storage 权限
    final status = await Permission.photos.request();
    return _mapStatus(status);
  }

  // ==================== 通知权限 ====================

  /// 请求通知权限
  ///
  /// 用于投喂提醒和健康观察提醒的场景。
  /// 在 Android 13+ 上需要显式请求通知权限。
  ///
  /// 返回值同 [requestCameraPermission]。
  static Future<PermissionResult> requestNotificationPermission() async {
    return _requestPermission(Permission.notification);
  }

  // ==================== 位置权限 ====================

  /// 请求位置权限（仅使用时获取）
  ///
  /// 用于记录发现猫咪的位置信息。
  /// 使用 `Permission.locationWhenInUse` 而非 `locationAlways`，
  /// 遵循最小权限原则——仅在 App 使用时获取位置。
  ///
  /// 返回值同 [requestCameraPermission]。
  static Future<PermissionResult> requestLocationPermission() async {
    return _requestPermission(Permission.locationWhenInUse);
  }

  /// 请求精确位置权限
  ///
  /// 如果需要获取精确位置（而非模糊位置），可调用此方法。
  /// 注意：在 Android 12+ 上，精确位置和模糊位置需要分别请求。
  static Future<PermissionResult> requestPreciseLocationPermission() async {
    return _requestPermission(Permission.location);
  }

  // ==================== 批量请求 ====================

  /// 请求所有必要权限
  ///
  /// 在应用首次启动时调用，一次性请求所有需要的权限。
  /// 返回一个 Map，包含每个权限的请求结果。
  ///
  /// 使用示例：
  /// ```dart
  /// final results = await PermissionUtils.requestAllPermissions();
  /// if (results[PermissionType.camera] == PermissionResult.granted) {
  ///   // 相机权限已授予
  /// }
  /// ```
  static Future<Map<PermissionType, PermissionResult>> requestAllPermissions() async {
    return {
      PermissionType.camera: await requestCameraPermission(),
      PermissionType.storage: await requestStoragePermission(),
      PermissionType.notification: await requestNotificationPermission(),
      PermissionType.location: await requestLocationPermission(),
    };
  }

  // ==================== 状态检查 ====================

  /// 检查相机权限是否已授予（不触发请求弹窗）
  static Future<bool> isCameraGranted() async {
    return await Permission.camera.status.isGranted;
  }

  /// 检查存储权限是否已授予（不触发请求弹窗）
  static Future<bool> isStorageGranted() async {
    return await Permission.photos.status.isGranted;
  }

  /// 检查通知权限是否已授予（不触发请求弹窗）
  static Future<bool> isNotificationGranted() async {
    return await Permission.notification.status.isGranted;
  }

  /// 检查位置权限是否已授予（不触发请求弹窗）
  static Future<bool> isLocationGranted() async {
    return await Permission.locationWhenInUse.status.isGranted;
  }

  // ==================== 私有辅助方法 ====================

  /// 通用权限请求方法
  static Future<PermissionResult> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      return _mapStatus(status);
    } catch (e) {
      // 权限请求过程中出现异常（如权限未在配置文件中声明）
      return PermissionResult.unknown;
    }
  }

  /// 将 permission_handler 的 PermissionStatus 映射为 PermissionResult
  static PermissionResult _mapStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult.granted;
      case PermissionStatus.denied:
        return PermissionResult.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionResult.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionResult.restricted;
      case PermissionStatus.limited:
        // iOS 14+ 的有限访问权限，视为已授予
        return PermissionResult.granted;
      case PermissionStatus.provisional:
        // iOS 的临时授权，视为已授予
        return PermissionResult.granted;
    }
  }
}

/// 权限类型枚举
///
/// 用于批量请求时标识不同的权限类型。
enum PermissionType {
  /// 相机权限
  camera,

  /// 存储权限
  storage,

  /// 通知权限
  notification,

  /// 位置权限
  location,
}
