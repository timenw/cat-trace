/// App 全局配置
class AppConfig {
  AppConfig._();

  static const String appName = '猫迹';
  static const String appNameEn = 'CatTrace';
  static const String version = '1.0.0';

  // 数据库
  static const String dbName = 'cat_trace_db';
  static const int dbVersion = 1;

  // 图片
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;
  static const int thumbnailSize = 300;

  // 分页
  static const int defaultPageSize = 20;

  // 成就
  static const int achievementFirstCat = 1;
  static const int achievementFiveCats = 5;
  static const int achievementTenCats = 10;
  static const int achievementFirstLog = 1;
  static const int achievementTenLogs = 10;
  static const int achievementFiftyLogs = 50;
  static const int achievementHundredLogs = 100;
  static const int achievementTnrAdvocate = 1;

  // 通知
  static const String notificationChannelId = 'cat_trace_reminders';
  static const String notificationChannelName = '投喂与健康提醒';

  // 备份
  static const String backupFileName = 'cat_trace_backup';
  static const String exportFileName = 'cat_trace_export';

  // 水印
  static const String watermarkPrefix = 'CT';
}
