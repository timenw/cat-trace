/// 依赖注入配置 — 使用 Riverpod Provider 注册所有仓库和服务
///
/// 本文件是整个应用的依赖注入（DI）入口，通过 Riverpod 的 Provider 机制
/// 将数据库、仓库、服务、通知等核心依赖统一注册和管理。
///
/// 架构层次：
///   - IsarDatabase（数据库层）
///   - Repository（仓库层）→ 依赖 IsarDatabase
///   - Service（服务层）→ 可依赖 Repository 和其他 Service
///
/// 使用方式：在 Widget 中通过 `ref.watch(provider)` 获取实例。

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/isar_database.dart';
import '../../features/cat/data/datasources/cat_local_datasource.dart';
import '../../features/cat/domain/repositories/cat_repository.dart';
import '../../features/cat/data/repositories/cat_repository_impl.dart';
import '../../features/log/data/datasources/log_local_datasource.dart';
import '../../features/log/data/repositories/log_repository_impl.dart';
import '../services/image_service.dart';
import '../services/notification_service.dart';
import '../services/watermark_service.dart';
import '../services/ai_recognition_service.dart';
import '../services/backup_service.dart';
import '../services/export_service.dart';

// ==================== 数据库层 Provider ====================

/// Isar 数据库实例 Provider
///
/// 这是一个 FutureProvider，因为数据库初始化是异步操作。
/// 其他依赖数据库的 Provider 通过 `ref.watch(isarProvider.future)` 获取实例。
final isarProvider = FutureProvider<Isar>((ref) async {
  return await IsarDatabase.initialize();
});

// ==================== 仓库层 Provider ====================

/// 猫咪仓库 Provider
///
/// 将 CatRepositoryImpl 注册为 CatRepository 的实现，
/// 业务层通过 CatRepository 接口与之交互，不依赖具体实现。
final catRepositoryProvider = FutureProvider<CatRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return CatRepositoryImpl(CatLocalDataSource(isar));
});

/// 日志仓库 Provider
///
/// 日志仓库目前没有抽象接口（直接使用实现类），
/// 如需解耦可自行添加 LogRepository 抽象类。
final logRepositoryProvider = FutureProvider<LogRepositoryImpl>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return LogRepositoryImpl(isar);
});

// ==================== 服务层 Provider ====================

/// 图片服务 Provider（单例）
///
/// ImageService 内部已实现单例模式，此处通过 Riverpod 统一管理其生命周期。
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

/// 通知服务 Provider（单例）
///
/// 负责本地推送通知的调度、取消和权限管理。
/// 应在应用启动时调用 `NotificationService.instance.initialize()`。
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// 水印服务 Provider（懒加载单例）
///
/// 负责给照片添加隐形水印（时间戳 + 随机ID），
/// 用于照片溯源和版权保护。
final watermarkServiceProvider = Provider<WatermarkService>((ref) {
  return WatermarkService();
});

/// AI 识别服务 Provider（懒加载单例）
///
/// 负责猫咪品种识别功能。
/// 当前为占位实现，预留 TFLite 接口供后续接入模型。
final aiRecognitionServiceProvider = Provider<AiRecognitionService>((ref) {
  return AiRecognitionService();
});

/// 备份服务 Provider
///
/// 负责本地数据的备份、恢复和导出功能。
/// 依赖 Isar 数据库实例和 ImageService。
final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final imageService = ref.watch(imageServiceProvider);
  return BackupService(
    isar: isar,
    imageService: imageService,
  );
});

/// 导出服务 Provider
///
/// 负责将用户数据导出为 PDF 或 Zip 压缩包格式。
/// 依赖 Isar 数据库实例用于读取数据。
final exportServiceProvider = FutureProvider<ExportService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ExportService(isar: isar);
});
