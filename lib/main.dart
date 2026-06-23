import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/isar_database.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

/// App 入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  await IsarDatabase.initialize();

  // 初始化通知服务
  await NotificationService().initialize();
  await NotificationService().createNotificationChannel();

  runApp(
    const ProviderScope(
      child: CatTraceApp(),
    ),
  );
}
