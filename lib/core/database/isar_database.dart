import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import 'schemas/cat_schema.dart';
import 'schemas/log_schema.dart';
import 'schemas/photo_schema.dart';
import 'schemas/achievement_schema.dart';

/// Isar 数据库管理
class IsarDatabase {
  static Isar? _instance;

  static Isar get instance {
    if (_instance == null) {
      throw StateError('IsarDatabase not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// 初始化数据库
  static Future<Isar> initialize() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [
        CatSchema,
        LogSchema,
        PhotoSchema,
        AchievementSchema,
      ],
      directory: dir.path,
      name: AppConstants.dbName,
      inspector: true, // 开发模式开启
    );
    return _instance!;
  }

  /// 关闭数据库
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }

  /// 清空所有数据
  static Future<void> clearAll() async {
    await instance.writeTxn(() async {
      await instance.clear();
    });
  }
}
