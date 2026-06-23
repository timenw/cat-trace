/// 日志类型枚举
enum LogType {
  feed('投喂', 'Feeding'),
  health('健康观察', 'Health'),
  note('观察笔记', 'Note');

  const LogType(this.displayName, this.displayNameEn);

  final String displayName;
  final String displayNameEn;

  static LogType fromString(String value) {
    return LogType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LogType.note,
    );
  }
}
