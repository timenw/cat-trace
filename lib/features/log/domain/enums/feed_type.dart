/// 食物类型枚举
enum FeedType {
  dryFood('干粮', 'Dry Food'),
  wetFood('湿粮', 'Wet Food'),
  treat('零食', 'Treat'),
  raw('生骨肉', 'Raw'),
  milk('羊奶', 'Milk'),
  other('其他', 'Other');

  const FeedType(this.displayName, this.displayNameEn);

  final String displayName;
  final String displayNameEn;

  static FeedType fromString(String value) {
    return FeedType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeedType.other,
    );
  }
}
