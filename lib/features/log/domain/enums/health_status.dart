/// 健康状态枚举
enum HealthStatus {
  excellent('非常好', 'Excellent'),
  good('良好', 'Good'),
  fair('一般', 'Fair'),
  poor('较差', 'Poor'),
  critical('危急', 'Critical');

  const HealthStatus(this.displayName, this.displayNameEn);

  final String displayName;
  final String displayNameEn;

  static HealthStatus fromString(String value) {
    return HealthStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HealthStatus.good,
    );
  }
}
