/// App 常量
class AppConstants {
  AppConstants._();

  // 数据库
  static const String dbName = 'cat_trace_db';
  static const int dbVersion = 1;

  // 图片
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;
  static const int thumbnailSize = 300;
  static const int maxPhotosPerCat = 50;
  static const int maxPhotosPerLog = 5;

  // 分页
  static const int defaultPageSize = 20;

  // 通知
  static const String notificationChannelId = 'cat_trace_reminders';
  static const String notificationChannelName = '投喂与健康提醒';
  static const String notificationChannelDesc = '提醒您投喂和观察流浪猫';

  // 备份
  static const String backupFileName = 'cat_trace_backup';
  static const String exportFileName = 'cat_trace_export';

  // 水印
  static const String watermarkPrefix = 'CT';

  // 默认提醒时间
  static const int defaultFeedReminderHour = 8;
  static const int defaultFeedReminderMinute = 0;
  static const int defaultHealthReminderHour = 20;
  static const int defaultHealthReminderMinute = 0;

  // 缓存
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDisclaimerAccepted = 'disclaimer_accepted';
  static const String keyPrivacyPolicyAccepted = 'privacy_policy_accepted';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyBackupEnabled = 'backup_enabled';
  static const String keyLocationEnabled = 'location_enabled';
  static const String keyLastBackupTime = 'last_backup_time';

  // 动画时长
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animCelebration = Duration(milliseconds: 1500);
}
